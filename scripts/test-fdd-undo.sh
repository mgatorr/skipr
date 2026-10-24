#!/usr/bin/env bash
# fdd undo: per-turn snapshots in refs of their own, never HEAD, branches or staging.
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

# A repo with one commit, one staged change and one ignored secret.
new_repo() {
  local dir="$1"
  mkdir -p "$dir"
  git -C "$dir" init -q -b main
  printf 'v1\n' >"$dir/app.txt"
  printf '.env\n' >"$dir/.gitignore"
  git -C "$dir" add app.txt .gitignore
  git -C "$dir" commit -q -m init
  printf 'staged\n' >"$dir/staged.txt"
  git -C "$dir" add staged.txt
  printf 'SECRET=1\n' >"$dir/.env"
}

state_of() {
  # HEAD, every branch, and the exact staging area.
  git -C "$1" rev-parse HEAD
  git -C "$1" for-each-ref refs/heads
  git -C "$1" ls-files -s
}

snaps() { git -C "$1" for-each-ref refs/worktree/fdd/ | wc -l | tr -d ' '; }

r="$work/repo with space"
new_repo "$r"
before="$(state_of "$r")"

# 1. A snapshot keeps untracked files, leaves out ignored and secret-looking ones.
printf 'KEY=2\n' >"$r/.env.local"
printf 'k\n' >"$r/deploy.pem"
printf 'new\n' >"$r/untracked.txt"
(cd "$r" && "$fdd" snapshot "start") >/dev/null
check "snapshot writes one ref" '[ "$(snaps "$r")" = 1 ]'
tree="$(git -C "$r" ls-tree -r --name-only refs/worktree/fdd/1)"
check "snapshot keeps untracked files" 'printf "%s\n" "$tree" | grep -qx untracked.txt'
check "snapshot keeps staged files" 'printf "%s\n" "$tree" | grep -qx staged.txt'
check "snapshot leaves out ignored .env" '! printf "%s\n" "$tree" | grep -qx .env'
check "snapshot leaves out unignored .env.local" '! printf "%s\n" "$tree" | grep -qx .env.local'
check "snapshot leaves out keys" '! printf "%s\n" "$tree" | grep -qx deploy.pem'
check "snapshot leaves HEAD, branches and staging alone" '[ "$(state_of "$r")" = "$before" ]'
check "git log does not show snapshots" '[ "$(git -C "$r" rev-list --count HEAD)" = 1 ]'

# 2. An unchanged tree adds no snapshot.
(cd "$r" && "$fdd" snapshot "again") >/dev/null
check "unchanged tree adds no snapshot" '[ "$(snaps "$r")" = 1 ]'

# 3. A turn edits, creates and deletes; undo puts every file back.
printf 'v2\n' >"$r/app.txt"
printf 'made by the turn\n' >"$r/created.txt"
mkdir -p "$r/new dir" && printf 'x\n' >"$r/new dir/nested.txt"
rm "$r/untracked.txt"
(cd "$r" && "$fdd" snapshot "after turn") >/dev/null
check "changed tree adds a snapshot" '[ "$(snaps "$r")" = 2 ]'
(cd "$r" && "$fdd" undo) >/dev/null 2>&1
check "undo restores an edited file" '[ "$(cat "$r/app.txt")" = v1 ]'
check "undo removes a created file" '[ ! -e "$r/created.txt" ]'
check "undo removes a created folder" '[ ! -e "$r/new dir" ]'
check "undo brings back a deleted file" '[ "$(cat "$r/untracked.txt" 2>/dev/null)" = new ]'
check "undo never touches ignored or secret files" '[ "$(cat "$r/.env")" = SECRET=1 ] && [ "$(cat "$r/.env.local")" = KEY=2 ] && [ -f "$r/deploy.pem" ]'
check "undo leaves HEAD, branches and staging alone" '[ "$(state_of "$r")" = "$before" ]'

# 4. Redo goes back to the undone state.
(cd "$r" && "$fdd" redo) >/dev/null 2>&1
check "redo restores the turn" '[ "$(cat "$r/app.txt")" = v2 ] && [ -f "$r/created.txt" ] && [ ! -e "$r/untracked.txt" ]'

# 5. Hand edits made after the last snapshot are kept before an undo.
printf 'by hand\n' >"$r/app.txt"
(cd "$r" && "$fdd" undo) >/dev/null 2>&1
check "undo first reverts hand edits to the last snapshot" '[ "$(cat "$r/app.txt")" = v2 ]'
(cd "$r" && "$fdd" redo) >/dev/null 2>&1
check "hand edits come back with redo" '[ "$(cat "$r/app.txt")" = "by hand" ]'

# 6. A new turn after an undo branches off; undo then follows the branch, not the number.
(cd "$r" && "$fdd" undo && "$fdd" undo) >/dev/null 2>&1
check "two undos reach the start" '[ "$(cat "$r/app.txt")" = v1 ]'
printf 'v3\n' >"$r/app.txt"
(cd "$r" && "$fdd" snapshot "other way") >/dev/null
(cd "$r" && "$fdd" undo) >/dev/null 2>&1
check "undo after a branch goes to its parent" '[ "$(cat "$r/app.txt")" = v1 ] && [ ! -e "$r/created.txt" ]'

# 7. Nothing to undo exits 1 and changes nothing.
ec=0
(cd "$r" && "$fdd" undo) >/dev/null 2>&1 || ec=$?
check "undo at the first snapshot exits 1" '[ "$ec" = 1 ]'
check "undo at the first snapshot changes nothing" '[ "$(cat "$r/app.txt")" = v1 ]'

# 8. History lists every snapshot and marks where the files are.
hist="$(cd "$r" && "$fdd" history 2>&1)"
check "history lists labels" 'printf "%s\n" "$hist" | grep -q "after turn" && printf "%s\n" "$hist" | grep -q "other way"'
check "history marks the current state" 'printf "%s\n" "$hist" | grep -q "^\* *#1 "'

# 9. Undo refuses to write over an untracked file a snapshot does not hold.
# The first snapshot holds build.log; then it is ignored and gets content no snapshot holds.
r2="$work/clash"
new_repo "$r2"
printf 'old\n' >"$r2/build.log"
(cd "$r2" && "$fdd" snapshot s1) >/dev/null
printf 'build.log\n' >>"$r2/.gitignore"
printf 'precious\n' >"$r2/build.log"
(cd "$r2" && "$fdd" snapshot s2) >/dev/null
gi_before="$(cat "$r2/.gitignore")"
ec=0
(cd "$r2" && "$fdd" undo) >/dev/null 2>&1 || ec=$?
check "undo over an ignored file exits non-zero" '[ "$ec" != 0 ]'
check "undo over an ignored file keeps it" '[ "$(cat "$r2/build.log")" = precious ]'
check "a refused undo moves no file" '[ "$(cat "$r2/.gitignore")" = "$gi_before" ]'

# 10. Outside a git repo: hooks must not fail, and nothing is written.
plain="$work/plain"
mkdir -p "$plain"
ec=0
(cd "$plain" && "$fdd" snapshot x) >/dev/null 2>&1 || ec=$?
check "snapshot outside git exits 0" '[ "$ec" = 0 ]'
check "snapshot outside git writes nothing" '[ -z "$(ls -A "$plain")" ]'

# 11. A repo with no commits yet.
r3="$work/unborn"
mkdir -p "$r3" && git -C "$r3" init -q -b main
printf 'a\n' >"$r3/a.txt"
(cd "$r3" && "$fdd" snapshot s1) >/dev/null
printf 'b\n' >"$r3/a.txt"
(cd "$r3" && "$fdd" snapshot s2 && "$fdd" undo) >/dev/null 2>&1
check "undo works before the first commit" '[ "$(cat "$r3/a.txt")" = a ]'

# 12. The hook reads Claude Code's JSON, labels by prompt and never fails.
printf 'hook edit\n' >"$r3/a.txt"
printf '{"hook_event_name":"UserPromptSubmit","cwd":"%s","prompt":"add a \\"login\\" page"}' "$r3" |
  (cd "$plain" && "$fdd" hook) >/dev/null 2>&1
check "hook snapshots the cwd from its JSON" 'git -C "$r3" log -1 --format=%s "$(git -C "$r3" for-each-ref --sort=-refname --format="%(objectname)" refs/worktree/fdd/ | head -1)" | grep -q "add a \"login\" page"'
ec=0
printf 'not json' | (cd "$plain" && "$fdd" hook) >/dev/null 2>&1 || ec=$?
check "hook with bad input exits 0" '[ "$ec" = 0 ]'

# 13. An edit of the same size right after a commit is still saved. Copying the
# index without its mtime made git trust stale stat data: 19 of 300 runs lost the
# edit. 100 runs miss that bug with a chance of about 0.2%.
lost=0
for i in $(seq 1 100); do
  rr="$work/racy$i"
  mkdir -p "$rr" && git -C "$rr" init -q
  printf 'aa\n' >"$rr/f" && git -C "$rr" add f && git -C "$rr" commit -q -m x
  printf 'bb\n' >"$rr/f"
  (cd "$rr" && "$fdd" snapshot s) >/dev/null
  [ "$(git -C "$rr" show refs/worktree/fdd/1:f)" = bb ] || lost=$((lost + 1))
  rm -rf "$rr"
done
check "same-size edits right after a commit are saved (lost $lost of 100)" '[ "$lost" = 0 ]'

# 14. A file that became a folder, and back.
r4="$work/swap"
new_repo "$r4"
printf 'file\n' >"$r4/x"
(cd "$r4" && "$fdd" snapshot s1) >/dev/null
rm "$r4/x" && mkdir "$r4/x" && printf 'y\n' >"$r4/x/y"
(cd "$r4" && "$fdd" snapshot s2) >/dev/null
(cd "$r4" && "$fdd" undo) >/dev/null 2>&1
check "undo turns a folder back into a file" '[ -f "$r4/x" ] && [ "$(cat "$r4/x")" = file ]'
(cd "$r4" && "$fdd" redo) >/dev/null 2>&1
check "redo turns the file back into a folder" '[ "$(cat "$r4/x/y" 2>/dev/null)" = y ]'
printf 'keep\n' >"$r4/x/ignored.log" && printf '*.log\n' >>"$r4/.gitignore"
(cd "$r4" && "$fdd" snapshot s3) >/dev/null
ec=0; (cd "$r4" && "$fdd" goto 1) >/dev/null 2>&1 || ec=$?
check "a folder holding an ignored file is not replaced" '[ "$ec" != 0 ] && [ "$(cat "$r4/x/ignored.log")" = keep ]'

# 15. GIT_DIR without GIT_WORK_TREE from a subfolder would treat it as the root: refuse.
r5="$work/gitdir"
new_repo "$r5"
mkdir -p "$r5/sub" && printf 'a\n' >"$r5/sub/a.txt"
ec=0; (cd "$r5/sub" && GIT_DIR="$r5/.git" "$fdd" snapshot s) >/dev/null 2>&1 || ec=$?
check "GIT_DIR without GIT_WORK_TREE is refused" '[ "$ec" != 0 ] && [ "$(snaps "$r5")" = 0 ]'
ec=0; (cd "$r5/sub" && printf '{"hook_event_name":"Stop","cwd":"%s"}' "$r5/sub" | GIT_DIR="$r5/.git" "$fdd" hook) >/dev/null 2>&1 || ec=$?
check "the hook with GIT_DIR alone exits 0 and saves nothing" '[ "$ec" = 0 ] && [ "$(snaps "$r5")" = 0 ]'

# 16. Large untracked files are left out, with a warning.
r6="$work/large"
new_repo "$r6"
head -c 2097152 /dev/zero >"$r6/export.mov"
err="$(cd "$r6" && FDD_MAX_FILE_MB=1 "$fdd" snapshot s 2>&1 >/dev/null)"
check "a file over the size limit is not saved" '! git -C "$r6" ls-tree -r --name-only refs/worktree/fdd/1 | grep -qx export.mov'
check "the size limit is reported on stderr" 'printf "%s\n" "$err" | grep -q export.mov'

# 17. Secret names, in any case.
r7="$work/case"
new_repo "$r7"
for f in .Env.local .env-local .envrc server.KEY id_dsa AuthKey_AB12.p8 .netrc; do printf 's\n' >"$r7/$f"; done
(cd "$r7" && "$fdd" snapshot s) >/dev/null
saved="$(git -C "$r7" ls-tree -r --name-only refs/worktree/fdd/1)"
for f in .Env.local .env-local .envrc server.KEY id_dsa AuthKey_AB12.p8 .netrc; do
  check "leaves out $f" '! printf "%s\n" "$saved" | grep -qxF "$f"'
done

# 18. Worktrees keep their own snapshots.
git -C "$r" worktree add -q "$work/wt" -b side >/dev/null 2>&1
check "a new worktree starts with no snapshots" '[ "$(snaps "$work/wt")" = 0 ]'

if [ "$fail" -eq 0 ]; then
  printf 'fdd undo: PASS\n'
  exit 0
fi
printf 'fdd undo: FAIL\n'
exit 1
