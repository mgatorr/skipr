#!/usr/bin/env bash
# Paths and link targets that contain a banned term must not be printed in clear.
# Content matching stays whole-word. The term here is a fake stand-in.
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
  OUT="$(cd "$work" && env -u CI -u GITHUB_ACTIONS DOCS_BANNED="$term" ./scripts/check-docs.sh "$@" 2>&1)" || EC=$?
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

# 5. clean path, content hit, still file:line. Glued word in content is not a hit.
work="$(new_repo)"
printf 'QAFAKETERM\n' > "$work/docs/qa1.md"
git -C "$work" add -f docs/qa1.md
git -C "$work" commit -qm content
run_repo "$work"
if [ "$EC" -ne 1 ]; then note "clean path exit $EC want 1"; fi
printf '%s\n' "$OUT" | grep -qx 'docs/qa1.md:1: banned term found' || note "clean path wanted file:line"
rm -rf "$work"

work="$(new_repo)"
printf 'x %s_notes y\n' "$term" > "$work/docs/qa1.md"
git -C "$work" add -f docs/qa1.md
git -C "$work" commit -qm gluedcontent
run_repo "$work"
if [ "$EC" -ne 0 ]; then note "glued content word exit $EC want 0"; fi
rm -rf "$work"

if [ "$fail" -eq 0 ]; then
  say "check-docs redaction: PASS"
  exit 0
fi
say "check-docs redaction: FAIL"
exit 1
