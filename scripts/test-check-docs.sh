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
  OUT="$(cd "$work" && env -u CI -u GITHUB_ACTIONS "$var=true" DOCS_BANNED= ./scripts/check-docs.sh 2>&1)" || EC=$?
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

if [ "$fail" -eq 0 ]; then
  say "check-docs redaction: PASS"
  exit 0
fi
say "check-docs redaction: FAIL"
exit 1
