#!/usr/bin/env bash
# Paths and link targets that contain a banned term must not be printed in clear.
# Content matching stays whole-word. The term here is a fake stand-in.
# check-docs.sh runs on the bash that runs this test, so /bin/bash checks bash 3.2.
set -u

root="$(cd "$(dirname "$0")/.." && pwd)"
src="$root/scripts/check-docs.sh"
term=qafaketerm
fail=0

say() { printf '%s\n' "$*"; }

run_repo() {
  local work="$1"
  shift
  EC=0
  OUT="$(cd "$work" && env -u CI -u GITHUB_ACTIONS DOCS_BANNED="$term" "$BASH" ./scripts/check-docs.sh "$@" 2>&1)" || EC=$?
}

new_repo() {
  local work
  work="$(mktemp -d)"
  mkdir -p "$work/scripts" "$work/docs"
  cp "$src" "$work/scripts/check-docs.sh"
  chmod +x "$work/scripts/check-docs.sh"
  git -C "$work" init -q
  git -C "$work" config user.email qa@example.invalid
  git -C "$work" config user.name qa
  printf 'ok\n' > "$work/README.md"
  git -C "$work" add README.md scripts/check-docs.sh
  git -C "$work" commit -qm base
  printf '%s\n' "$work"
}

leaks() {
  printf '%s\n' "$OUT" | grep -qi "$term"
}

note() { say "FAIL $*"; fail=1; }

# 1. content hit in a path that glues the term with _ or camelCase
for name in "docs/${term}_notes.md" "docs/QafaketermNotes.md"; do
  work="$(new_repo)"
  mkdir -p "$work/$(dirname "$name")"
  printf 'QAFAKETERM\n' > "$work/$name"
  git -C "$work" add -f "$name"
  git -C "$work" commit -qm hit
  run_repo "$work"
  if [ "$EC" -ne 1 ]; then note "glued $name exit $EC want 1"; fi
  if leaks; then note "glued $name printed the term"; fi
  printf '%s\n' "$OUT" | grep -qE '^\[path#[0-9a-f]{12}\]:[0-9]+: banned term found$' || note "glued $name wanted a hashed content hit"
  rm -rf "$work"
done

# 2. path-only, term glued into the file name, clean content
work="$(new_repo)"
printf 'clean line\n' > "$work/docs/${term}_notes.md"
git -C "$work" add -f "docs/${term}_notes.md"
git -C "$work" commit -qm path
run_repo "$work"
if [ "$EC" -ne 1 ]; then note "path-only glued exit $EC want 1"; fi
if leaks; then note "path-only glued printed the term"; fi
printf '%s\n' "$OUT" | grep -qE '^\[path#[0-9a-f]{12}\]$' || note "path-only glued wanted [path#hash] alone"
rm -rf "$work"

# 3. broken link whose target holds the term
work="$(new_repo)"
printf 'see [x](./%s.md)\n' "$term" > "$work/docs/qa-link.md"
git -C "$work" add -f docs/qa-link.md
git -C "$work" commit -qm link
run_repo "$work"
if [ "$EC" -ne 1 ]; then note "link target exit $EC want 1"; fi
if leaks; then note "link target printed the term"; fi
printf '%s\n' "$OUT" | grep -q 'missing \./'"$term" && note "link target printed in clear"
rm -rf "$work"

# 4. broken link inside a directory whose name holds the term
work="$(new_repo)"
mkdir -p "$work/docs/$term"
printf 'see [x](./nope.md)\n' > "$work/docs/$term/notes.md"
git -C "$work" add -f "docs/$term/notes.md"
git -C "$work" commit -qm dirlink
run_repo "$work"
if [ "$EC" -ne 1 ]; then note "dir link exit $EC want 1"; fi
if leaks; then note "dir link printed the term"; fi
printf '%s\n' "$OUT" | grep -q "docs/$term/" && note "dir link printed the path in clear"
rm -rf "$work"

# 5. clean path, content hit, still file:line.
work="$(new_repo)"
printf 'QAFAKETERM\n' > "$work/docs/qa1.md"
git -C "$work" add -f docs/qa1.md
git -C "$work" commit -qm content
run_repo "$work"
if [ "$EC" -ne 1 ]; then note "clean path exit $EC want 1"; fi
printf '%s\n' "$OUT" | grep -qx 'docs/qa1.md:1: banned term found' || note "clean path wanted file:line"
rm -rf "$work"

# The rest uses the fake term zorblax.
term=zorblax

# 6. underscores do not hide a term in content; possessive and uppercase still hit
for text in '_zorblax_' '__zorblax__' 'zorblax_client' "zorblax's" 'ZORBLAX'; do
  work="$(new_repo)"
  printf 'x %s y\n' "$text" > "$work/docs/qa1.md"
  git -C "$work" add -f docs/qa1.md
  git -C "$work" commit -qm underscore
  run_repo "$work"
  if [ "$EC" -ne 1 ]; then note "content $text exit $EC want 1"; fi
  if leaks; then note "content $text printed the term"; fi
  printf '%s\n' "$OUT" | grep -qx 'docs/qa1.md:1: banned term found' || note "content $text wanted file:line"
  rm -rf "$work"
done

# 7. in CI an empty DOCS_BANNED fails even when a .docs-banned decoy is committed
for var in CI GITHUB_ACTIONS; do
  work="$(new_repo)"
  printf 'decoy\n' > "$work/.docs-banned"
  printf 'x %s y\n' "$term" > "$work/docs/qa1.md"
  git -C "$work" add -f .docs-banned docs/qa1.md
  git -C "$work" commit -qm decoy
  EC=0
  OUT="$(cd "$work" && env -u CI -u GITHUB_ACTIONS "$var=true" DOCS_BANNED= "$BASH" ./scripts/check-docs.sh 2>&1)" || EC=$?
  if [ "$EC" -ne 1 ]; then note "CI ($var) with decoy exit $EC want 1"; fi
  printf '%s\n' "$OUT" | grep -qx 'DOCS_BANNED secret not set' || note "CI ($var) with decoy wanted 'DOCS_BANNED secret not set'"
  rm -rf "$work"
done

# 8. a tracked symlink whose target holds the term, dangling or not
for kind in dangling live; do
  work="$(new_repo)"
  if [ "$kind" = live ]; then
    printf 'clean\n' > "$work/docs/${term}-target.md"
    git -C "$work" add -f "docs/${term}-target.md"
    # the target path is checked on its own; the test is about the link
    ln -s "./${term}-target.md" "$work/docs/link.md"
  else
    ln -s "../${term}-gone.md" "$work/docs/link.md"
  fi
  git -C "$work" add -f docs/link.md
  git -C "$work" commit -qm symlink
  run_repo "$work"
  if [ "$EC" -ne 1 ]; then note "symlink $kind exit $EC want 1"; fi
  if leaks; then note "symlink $kind printed the term"; fi
  printf '%s\n' "$OUT" | grep -qE '^docs/link\.md: symlink target \[path#[0-9a-f]{12}\]$' || note "symlink $kind wanted a hashed target"
  rm -rf "$work"
done

# A dangling symlink whose own path holds the term, with a clean target.
work="$(new_repo)"
ln -s ./gone.md "$work/docs/${term}-link.md"
git -C "$work" add -f "docs/${term}-link.md"
git -C "$work" commit -qm symlinkpath
run_repo "$work"
if [ "$EC" -ne 1 ]; then note "symlink path exit $EC want 1"; fi
if leaks; then note "symlink path printed the term"; fi
printf '%s\n' "$OUT" | grep -qE '^\[path#[0-9a-f]{12}\]$' || note "symlink path wanted [path#hash]"
rm -rf "$work"

# 9. a Latin-1 text file (not valid UTF-8) is still scanned
work="$(new_repo)"
printf 'caf\351 %s\n' "$term" > "$work/docs/latin1.txt"
git -C "$work" add -f docs/latin1.txt
git -C "$work" commit -qm latin1
run_repo "$work"
if [ "$EC" -ne 1 ]; then note "latin-1 exit $EC want 1"; fi
printf '%s\n' "$OUT" | grep -qx 'docs/latin1.txt:1: banned term found' || note "latin-1 wanted file:line"
rm -rf "$work"

# A binary file (NUL bytes) stays skipped.
work="$(new_repo)"
printf '\000\001 %s\n' "$term" > "$work/docs/blob.bin"
git -C "$work" add -f docs/blob.bin
git -C "$work" commit -qm binary
run_repo "$work"
if [ "$EC" -ne 0 ]; then note "binary exit $EC want 0"; fi
rm -rf "$work"

# 10. an unreadable file is reported without its raw path
work="$(new_repo)"
printf 'see [x](./nope.md)\n' > "$work/docs/${term}.md"
git -C "$work" add -f "docs/${term}.md"
git -C "$work" commit -qm unreadable
chmod 000 "$work/docs/${term}.md"
if [ -r "$work/docs/${term}.md" ]; then
  say "skip unreadable case: running as a user that can read mode 000"
else
  run_repo "$work"
  if [ "$EC" -ne 1 ]; then note "unreadable exit $EC want 1"; fi
  if leaks; then note "unreadable printed the term"; fi
  printf '%s\n' "$OUT" | grep -qE '^\[path#[0-9a-f]{12}\]: unreadable$' || note "unreadable wanted [path#hash]: unreadable"
fi
chmod 644 "$work/docs/${term}.md"
rm -rf "$work"

# 11. 'One task per session' in docs/novice-guide.md: required, at most 20
# lines (heading included, trailing blank lines and --- rules not counted);
# the setup-harness CLAUDE.md template must name /clear.
section="One task per session"
guide_fixture() { # work body-lines
  local work="$1" n="$2" i=1
  {
    printf '# Guide\n\n## Before\n\nx\n\n'
    printf '## %s\n' "$section"
    while [ "$i" -lt "$n" ]; do printf 'line %s\n' "$i"; i=$((i + 1)); done
    printf '\n---\n\n## After\n\n'
    i=1
    while [ "$i" -le 30 ]; do printf 'after %s\n' "$i"; i=$((i + 1)); done
  } > "$work/docs/novice-guide.md"
}
template_fixture() { # work text
  mkdir -p "$1/skills/setup-harness/templates"
  printf '# T\n\n- %s\n' "$2" > "$1/skills/setup-harness/templates/CLAUDE.md"
}
commit_all() {
  git -C "$1" add -f docs/novice-guide.md skills/setup-harness/templates/CLAUDE.md
  git -C "$1" commit -qm fixture
}
template_ok='When the task is done or the topic changes, tell the human to type /clear.'

# A compliant fixture passes: 20 lines, then a rule and a 30-line section.
work="$(new_repo)"
guide_fixture "$work" 20
template_fixture "$work" "$template_ok"
commit_all "$work"
run_repo "$work"
if [ "$EC" -ne 0 ]; then note "compliant section exit $EC want 0: $OUT"; fi
printf '%s\n' "$OUT" | grep -qx 'docs check ok' || note "compliant section wanted 'docs check ok'"
rm -rf "$work"

# A 21-line section fails and names file, heading, count and cap.
work="$(new_repo)"
guide_fixture "$work" 21
template_fixture "$work" "$template_ok"
commit_all "$work"
run_repo "$work"
if [ "$EC" -ne 1 ]; then note "21-line section exit $EC want 1"; fi
printf '%s\n' "$OUT" | grep -qx "docs/novice-guide.md: section $section has 21 lines (cap 20)" || note "21-line section wanted the cap message: $OUT"
rm -rf "$work"

# A guide without the heading fails.
work="$(new_repo)"
printf '# Guide\n\n## Before\n\nx\n' > "$work/docs/novice-guide.md"
template_fixture "$work" "$template_ok"
commit_all "$work"
run_repo "$work"
if [ "$EC" -ne 1 ]; then note "missing heading exit $EC want 1"; fi
printf '%s\n' "$OUT" | grep -qx "docs/novice-guide.md: missing heading $section" || note "missing heading wanted the message: $OUT"
rm -rf "$work"

# A template without /clear fails; the guide is compliant.
work="$(new_repo)"
guide_fixture "$work" 12
template_fixture "$work" 'One task per session.'
commit_all "$work"
run_repo "$work"
if [ "$EC" -ne 1 ]; then note "template without /clear exit $EC want 1"; fi
printf '%s\n' "$OUT" | grep -qx 'skills/setup-harness/templates/CLAUDE.md: missing /clear' || note "template without /clear wanted the message: $OUT"
rm -rf "$work"

# 12. The real tree passes: the section and the template line are in.
real_term="$(printf '%s%s' qx9 nothere)"
EC=0
OUT="$(cd "$root" && env -u CI -u GITHUB_ACTIONS DOCS_BANNED="$real_term" "$BASH" ./scripts/check-docs.sh 2>&1)" || EC=$?
if [ "$EC" -ne 0 ]; then note "real tree exit $EC want 0: $OUT"; fi
printf '%s\n' "$OUT" | grep -qx 'docs check ok' || note "real tree wanted 'docs check ok'"

# 13. skills/fdd/models.md: at most 50 lines, with an 'Agents and workflows'
# section of at most 12 lines (heading included).
models_fixture() { # work section-lines (0 = no heading) total-lines
  local work="$1" s="$2" total="$3" i=1 n
  mkdir -p "$work/skills/fdd"
  {
    printf '# Model per task\n\nx\n\n'
    n=4
    if [ "$s" -gt 0 ]; then
      printf '## Agents and workflows\n'
      n=$((n + 1))
      while [ "$i" -lt "$s" ]; do printf -- '- agent %s\n' "$i"; i=$((i + 1)); n=$((n + 1)); done
      printf '\n'
      n=$((n + 1))
    fi
    printf '## Prices\n'
    n=$((n + 1))
    while [ "$n" -lt "$total" ]; do printf 'price %s\n' "$n"; n=$((n + 1)); done
  } > "$work/skills/fdd/models.md"
  git -C "$work" add -f skills/fdd/models.md
  git -C "$work" commit -qm models
}

# A 50-line file with a 12-line section passes.
work="$(new_repo)"
models_fixture "$work" 12 50
run_repo "$work"
if [ "$EC" -ne 0 ]; then note "compliant models.md exit $EC want 0: $OUT"; fi
printf '%s\n' "$OUT" | grep -qx 'docs check ok' || note "compliant models.md wanted 'docs check ok'"
[ "$(wc -l < "$work/skills/fdd/models.md" | tr -d ' ')" = 50 ] || note "compliant models.md fixture is not 50 lines"
rm -rf "$work"

# A 51-line file fails and names the count and the cap.
work="$(new_repo)"
models_fixture "$work" 12 51
run_repo "$work"
if [ "$EC" -ne 1 ]; then note "51-line models.md exit $EC want 1"; fi
printf '%s\n' "$OUT" | grep -qx 'skills/fdd/models.md has 51 lines (cap 50)' || note "51-line models.md wanted the cap message: $OUT"
rm -rf "$work"

# A file without the heading fails.
work="$(new_repo)"
models_fixture "$work" 0 30
run_repo "$work"
if [ "$EC" -ne 1 ]; then note "models.md without the heading exit $EC want 1"; fi
printf '%s\n' "$OUT" | grep -qx 'skills/fdd/models.md: missing heading Agents and workflows' || note "models.md without the heading wanted the message: $OUT"
rm -rf "$work"

# A 13-line section fails.
work="$(new_repo)"
models_fixture "$work" 13 40
run_repo "$work"
if [ "$EC" -ne 1 ]; then note "13-line agents section exit $EC want 1"; fi
printf '%s\n' "$OUT" | grep -qx 'skills/fdd/models.md: section Agents and workflows has 13 lines (cap 12)' || note "13-line agents section wanted the cap message: $OUT"
rm -rf "$work"

if [ "$fail" -eq 0 ]; then
  say "check-docs redaction: PASS"
  exit 0
fi
say "check-docs redaction: FAIL"
exit 1
