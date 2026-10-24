#!/usr/bin/env bash
# fdd commit: conventional message, secret scan of what is staged, no Claude
# attribution, the owner's co-author trailer, and no push unless asked.
set -u

root="$(cd "$(dirname "$0")/.." && pwd)"
fdd="$root/skills/fdd/bin/fdd"
fail=0
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com
export GIT_CONFIG_NOSYSTEM=1 HOME="$work/home"
mkdir -p "$HOME"

pass() { printf 'PASS %s\n' "$1"; }
bad() { printf 'FAIL %s\n' "$1"; fail=1; }
check() { if eval "$2"; then pass "$1"; else bad "$1"; fi; }

new_repo() {
  local dir="$1"
  git init -q --bare "$dir.remote.git"
  mkdir -p "$dir"
  git -C "$dir" init -q -b feature
  git -C "$dir" remote add origin "$dir.remote.git"
  printf 'v1\n' >"$dir/app.txt"
  git -C "$dir" add app.txt
  git -C "$dir" commit -q -m "chore: init"
  git -C "$dir" push -q -u origin feature 2>/dev/null
}
count() { git -C "$1" rev-list --count HEAD; }

# A token shaped like a GitHub one, built at run time so this file holds none.
token="gh""p_$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 36)"

# A gitleaks that errors out must not let a secret through.
printf '#!/bin/sh\nexit 3\n' >"$work/broken-gitleaks" && chmod +x "$work/broken-gitleaks"

for scanner in default none broken; do
  case "$scanner" in
    default) unset FDD_GITLEAKS ;;
    none) export FDD_GITLEAKS=none ;;
    broken) export FDD_GITLEAKS="$work/broken-gitleaks" ;;
  esac
  s="[$scanner scanner]"
  r="$work/repo-$scanner"
  new_repo "$r"

  # 1. Messages must be Conventional Commits with a short subject.
  printf 'v2\n' >"$r/app.txt" && git -C "$r" add app.txt
  ec=0; (cd "$r" && "$fdd" commit "updated stuff") >/dev/null 2>&1 || ec=$?
  check "$s rejects a non-conventional message" '[ "$ec" = 1 ] && [ "$(count "$r")" = 1 ]'
  ec=0; (cd "$r" && "$fdd" commit "feat: $(printf 'x%.0s' $(seq 1 70))") >/dev/null 2>&1 || ec=$?
  check "$s rejects a subject over 72 characters" '[ "$ec" = 1 ] && [ "$(count "$r")" = 1 ]'

  # 2. A good message commits what is staged, and nothing is pushed.
  out="$(cd "$r" && "$fdd" commit "feat(app): bump to v2" 2>&1)"
  check "$s commits a conventional message" '[ "$(count "$r")" = 2 ] && [ "$(git -C "$r" log -1 --format=%s)" = "feat(app): bump to v2" ]'
  check "$s does not push by default" '[ "$(count "$r")" = 2 ] && [ "$(git -C "$r.remote.git" rev-list --count feature)" = 1 ]'
  check "$s says it did not push" 'printf "%s\n" "$out" | grep -qi "not pushed"'

  # 3. Nothing staged is an error.
  ec=0; (cd "$r" && "$fdd" commit "fix: nothing") >/dev/null 2>&1 || ec=$?
  check "$s nothing staged exits 1" '[ "$ec" = 1 ] && [ "$(count "$r")" = 2 ]'

  # 4. Paths after -- are staged and only they are committed.
  printf 'a\n' >"$r/a.txt"; printf 'b\n' >"$r/b.txt"
  (cd "$r" && "$fdd" commit "feat: add a" -- a.txt) >/dev/null 2>&1
  check "$s commits only the given paths" '[ "$(git -C "$r" show --name-only --format= HEAD)" = a.txt ] && [ -n "$(git -C "$r" status --porcelain b.txt)" ]'

  # 5. A secret-looking file staged by force is refused.
  printf 'K=1\n' >"$r/.env.local" && git -C "$r" add -f .env.local
  ec=0; (cd "$r" && "$fdd" commit "chore: env") >/dev/null 2>&1 || ec=$?
  check "$s refuses a staged .env file" '[ "$ec" = 1 ] && [ "$(count "$r")" = 3 ]'
  git -C "$r" rm -q --cached .env.local

  # 6. A token in the staged diff is refused, and the output never shows it.
  printf 'token = "%s"\n' "$token" >"$r/config.txt" && git -C "$r" add config.txt
  ec=0; out="$(cd "$r" && "$fdd" commit "feat: config" 2>&1)" || ec=$?
  check "$s refuses a staged token" '[ "$ec" = 1 ] && [ "$(count "$r")" = 3 ]'
  check "$s never prints the token" '! printf "%s\n" "$out" | grep -q "$token"'
  check "$s names the file" 'printf "%s\n" "$out" | grep -q config.txt'
  git -C "$r" rm -q --cached config.txt && rm "$r/config.txt"

  # 7. Claude attribution is removed; the owner's co-author trailer is added once.
  git -C "$r" config fdd.coauthor "Owner Name <1+owner@users.noreply.github.com>"
  printf 'c\n' >"$r/c.txt" && git -C "$r" add c.txt
  body="$(printf 'Why: c is needed.\n\nCo-Authored-By: Claude Opus <noreply@anthropic.com>\n🤖 Generated with [Claude Code](https://claude.com/claude-code)\nClaude-Session: https://claude.ai/code/abc')"
  (cd "$r" && "$fdd" commit "feat: add c" --body "$body") >/dev/null 2>&1
  msg="$(git -C "$r" log -1 --format=%B)"
  check "$s keeps the body" 'printf "%s\n" "$msg" | grep -q "Why: c is needed."'
  check "$s drops Claude attribution" '[ "$(git -C "$r" log -1 --format=%s)" = "feat: add c" ] && ! printf "%s\n" "$msg" | grep -qi -e claude -e anthropic'
  check "$s adds the co-author once" '[ "$(printf "%s\n" "$msg" | grep -c "^Co-Authored-By: Owner Name <1+owner@users.noreply.github.com>$")" = 1 ]'

  # 8. --push pushes the current branch.
  printf 'd\n' >"$r/d.txt" && git -C "$r" add d.txt
  (cd "$r" && "$fdd" commit "feat: add d" --push) >/dev/null 2>&1
  check "$s --push pushes" '[ "$(git -C "$r" log -1 --format=%s)" = "feat: add d" ] && [ "$(git -C "$r.remote.git" rev-parse feature)" = "$(git -C "$r" rev-parse HEAD)" ]'
done

# 9. The built-in scan does not depend on diff prefixes or quoted names.
export FDD_GITLEAKS=none
q="$work/quoted"
new_repo "$q"
git -C "$q" config diff.noprefix true
printf 'token = "%s"\n' "$token" >"$q/a.txt" && git -C "$q" add a.txt
ec=0; (cd "$q" && "$fdd" commit "feat: a") >/dev/null 2>&1 || ec=$?
check "refuses a token with diff.noprefix set" '[ "$ec" = 1 ] && [ "$(count "$q")" = 1 ]'
git -C "$q" rm -q --cached a.txt && rm "$q/a.txt"
printf 'token = "%s"\n' "$token" >"$q/café.txt" && git -C "$q" add café.txt
ec=0; out="$(cd "$q" && "$fdd" commit "feat: cafe" 2>&1)" || ec=$?
check "refuses a token in a file git quotes" '[ "$ec" = 1 ] && [ "$(count "$q")" = 1 ]'
check "names the quoted file" 'printf "%s\n" "$out" | grep -q "café.txt"'
git -C "$q" rm -q --cached café.txt && rm "$q/café.txt"
unset FDD_GITLEAKS

# 10. Only attribution trailers go; a subject or a body that mentions Claude stays.
printf 'e\n' >"$q/e.txt" && git -C "$q" add e.txt
(cd "$q" && "$fdd" commit "fix(fdd): drop Generated with Claude lines" --body "See claude.ai/code for the session format. This was generated by Claude at first.") >/dev/null 2>&1
check "a subject that mentions Claude is kept" '[ "$(git -C "$q" log -1 --format=%s)" = "fix(fdd): drop Generated with Claude lines" ]'
check "a body line that mentions claude.ai/code is kept" 'git -C "$q" log -1 --format=%B | grep -q "See claude.ai/code" && git -C "$q" log -1 --format=%B | grep -q "generated by Claude at first"'

# 11. --body with no value is an error, not a hang.
printf 'f\n' >"$q/f.txt" && git -C "$q" add f.txt
( cd "$q" && "$fdd" commit "feat: f" --body ) >/dev/null 2>&1 &
pid=$!
for i in 1 2 3 4 5 6 7 8 9 10; do kill -0 "$pid" 2>/dev/null || break; sleep 0.5; done
if kill -0 "$pid" 2>/dev/null; then kill "$pid"; hung=1; else hung=0; fi
wait "$pid" 2>/dev/null; ec=$?
check "--body with no value exits 1 at once" '[ "$hung" = 0 ] && [ "$ec" = 1 ]'

# 12. The first commit of a repository.
u="$work/unborn"
mkdir -p "$u" && git -C "$u" init -q -b main
printf 'x\n' >"$u/x.txt"
(cd "$u" && "$fdd" commit "chore: first" -- x.txt) >/dev/null 2>&1
check "first commit of a repository" '[ "$(git -C "$u" log -1 --format=%s 2>/dev/null)" = "chore: first" ]'

if [ "$fail" -eq 0 ]; then
  printf 'fdd commit: PASS\n'
  exit 0
fi
printf 'fdd commit: FAIL\n'
exit 1
