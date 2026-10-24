#!/usr/bin/env bash
# Scenarios for scripts/install-macos.sh.
# On Linux, uname -s is shimmed to Darwin so the macOS-only script can run.
# Scenario 4 freezes `date` so two --force runs share one second, then checks
# no *bak* under skills, distinct backup suffixes, one name each, rules untouched.
# Scenario 9 shims mktemp to fail and records cp destinations.
# Scenario 10 fails only the clone-path mktemp -d and records git clone.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
INSTALLER="$REPO/scripts/install-macos.sh"
ORIG_PATH="$PATH"
REAL_UNAME="$(command -v uname)"
REAL_DATE="$(command -v date)"
SHIM=""
fail=0

if [ "$("$REAL_UNAME" -s)" != "Darwin" ]; then
  SHIM="$(mktemp -d)"
  cat > "$SHIM/uname" <<EOF
#!/bin/sh
if [ "\${1:-}" = "-s" ]; then
  printf '%s\n' Darwin
  exit 0
fi
exec "$REAL_UNAME" "\$@"
EOF
  chmod +x "$SHIM/uname"
  ORIG_PATH="$SHIM:$ORIG_PATH"
fi

cleanup() {
  [ -n "$SHIM" ] && rm -rf "$SHIM"
}
trap cleanup EXIT

say() { printf '%s\n' "$*"; }

# reasons accumulate for the current scenario
reasons=""
note() { reasons="${reasons}${reasons:+; }$*"; }

begin() {
  reasons=""
  say "-- scenario $1"
}

finish() {
  local n="$1"
  if [ -n "$reasons" ]; then
    say "scenario $n: FAIL $reasons"
    fail=1
  else
    say "scenario $n: PASS"
  fi
}

new_home() {
  local work
  work="$(mktemp -d)"
  mkdir -p "$work/home dir"
  printf '%s\n' "$work"
}

run_inst() {
  # run_inst LOG HOME [installer-args...]
  local log="$1" home="$2"
  shift 2
  EC=0
  env -u GIT_DIR -u GIT_WORK_TREE \
    HOME="$home" PATH="$ORIG_PATH" SKIPR_REPO_URL="$REPO" \
    bash "$INSTALLER" "$@" </dev/null >"$log" 2>&1 || EC=$?
}

no_backup_under_skills() {
  local home="$1" skills hit
  skills="$home/.claude/skills"
  [ -d "$skills" ] || return 0
  hit="$(find "$skills" \( -name '*.bak*' -o -name 'backup' -o -name 'skills-backup' \) -print | head -n 1)"
  if [ -n "$hit" ]; then
    note "backup left under skills ($hit)"
    return 1
  fi
  return 0
}

seed_skill() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  rm -rf "$dest"
  cp -R "$src" "$dest"
}

# --- 1. clean home: both skills match the source ---
begin 1
{
  work="$(new_home)"
  home="$work/home dir"
  log="$work/log"
  run_inst "$log" "$home"
  [ "$EC" -eq 0 ] || note "exit $EC"
  if [ -d "$home/.claude/skills/setup-harness" ]; then
    diff -rq "$REPO/skills/setup-harness" "$home/.claude/skills/setup-harness" >/dev/null || note "setup-harness differs from source"
  else
    note "setup-harness missing"
  fi
  if [ -d "$home/.claude/skills/fdd" ]; then
    diff -rq "$REPO/skills/fdd" "$home/.claude/skills/fdd" >/dev/null || note "fdd differs from source"
  else
    note "fdd missing"
  fi
  if find "$home" -name '*.bak*' -print | grep -q .; then
    note "found a .bak"
  fi
  no_backup_under_skills "$home" || true
  finish 1
  rm -rf "$work"
}

# --- 2. existing config, no --force: byte-identical, no backup ---
begin 2
{
  work="$(new_home)"
  home="$work/home dir"
  log="$work/log"
  seed_skill "$REPO/skills/setup-harness" "$home/.claude/skills/setup-harness"
  seed_skill "$REPO/skills/fdd" "$home/.claude/skills/fdd"
  printf 'edited\n' > "$home/.claude/skills/setup-harness/EDITED.txt"
  printf 'edited\n' > "$home/.claude/skills/fdd/EDITED.txt"
  mkdir -p "$home/.claude/skills/other-skill"
  printf 'sibling\n' > "$home/.claude/skills/other-skill/keep.txt"
  printf '{}\n' > "$home/.claude/settings.json"
  printf '# zshrc\n' > "$home/.zshrc"
  snap="$work/snap"
  mkdir -p "$snap"
  cp -R "$home"/. "$snap"/
  run_inst "$log" "$home"
  [ "$EC" -eq 0 ] || note "exit $EC"
  diff -rq "$snap" "$home" >/dev/null || note "home tree changed"
  if [ -d "$home/.claude/skills-backup" ] || find "$home" -name '*.bak*' -print | grep -q .; then
    note "backup was created"
  fi
  no_backup_under_skills "$home" || true
  finish 2
  rm -rf "$work"
}

# --- 3. --force: one outside backup per skill, sibling kept ---
begin 3
{
  work="$(new_home)"
  home="$work/home dir"
  log="$work/log"
  seed_skill "$REPO/skills/setup-harness" "$home/.claude/skills/setup-harness"
  seed_skill "$REPO/skills/fdd" "$home/.claude/skills/fdd"
  printf 'marker-setup\n' > "$home/.claude/skills/setup-harness/MARKER.txt"
  printf 'marker-fdd\n' > "$home/.claude/skills/fdd/MARKER.txt"
  mkdir -p "$home/.claude/skills/other-skill"
  printf 'sibling\n' > "$home/.claude/skills/other-skill/keep.txt"
  printf '{}\n' > "$home/.claude/settings.json"
  printf '# zshrc\n' > "$home/.zshrc"
  run_inst "$log" "$home" --force
  [ "$EC" -eq 0 ] || note "exit $EC"
  broot="$home/.claude/skills-backup"
  nsetup=0
  nfdd=0
  if [ -d "$broot" ]; then
    nsetup="$(find "$broot" -mindepth 1 -maxdepth 1 -type d -name 'setup-harness.*' | wc -l | tr -d ' ')"
    nfdd="$(find "$broot" -mindepth 1 -maxdepth 1 -type d -name 'fdd.*' | wc -l | tr -d ' ')"
  fi
  [ "$nsetup" = "1" ] || note "setup-harness backups=$nsetup"
  [ "$nfdd" = "1" ] || note "fdd backups=$nfdd"
  setup_bak="$(find "$broot" -mindepth 1 -maxdepth 1 -type d -name 'setup-harness.*' 2>/dev/null | head -n 1)"
  fdd_bak="$(find "$broot" -mindepth 1 -maxdepth 1 -type d -name 'fdd.*' 2>/dev/null | head -n 1)"
  if [ -n "$setup_bak" ] && [ -f "$setup_bak/MARKER.txt" ]; then
    :
  else
    note "setup-harness backup missing marker"
  fi
  if [ -n "$fdd_bak" ] && [ -f "$fdd_bak/MARKER.txt" ]; then
    :
  else
    note "fdd backup missing marker"
  fi
  if [ -f "$home/.claude/skills/other-skill/keep.txt" ]; then
    :
  else
    note "sibling skill missing"
  fi
  grep -qx '{}' "$home/.claude/settings.json" || note "settings.json changed"
  grep -qx '# zshrc' "$home/.zshrc" || note ".zshrc changed"
  diff -rq "$REPO/skills/setup-harness" "$home/.claude/skills/setup-harness" >/dev/null || note "setup-harness was not replaced from source"
  diff -rq "$REPO/skills/fdd" "$home/.claude/skills/fdd" >/dev/null || note "fdd was not replaced from source"
  no_backup_under_skills "$home" || true
  finish 3
  rm -rf "$work"
}

# --- 4. re-run, then two --force in the same second ---
begin 4
{
  work="$(new_home)"
  home="$work/home dir"
  log="$work/log"
  proj="$home/Projects/keep"
  rules="$proj/.skipr/rules.md"
  mkdir -p "$proj/.skipr"
  printf '%s\n' '- keep this rule (qa, 2026-01-01, own)' > "$rules"
  cp "$rules" "$work/rules.md.orig"
  saved_pwd="$(pwd)"
  cd "$proj"
  run_inst "$log" "$home"
  [ "$EC" -eq 0 ] || note "first exit $EC"
  snap="$work/snap"
  mkdir -p "$snap"
  cp -R "$home"/. "$snap"/
  run_inst "$log" "$home"
  [ "$EC" -eq 0 ] || note "second exit $EC"
  diff -rq "$snap" "$home" >/dev/null || note "second run without --force changed the tree"
  # Freeze the clock so both --force runs share a second.
  dateshim="$(mktemp -d)"
  cat > "$dateshim/date" <<EOF
#!/bin/sh
printf '%s\n' 20260101T000000Z
exit 0
EOF
  chmod +x "$dateshim/date"
  saved_path="$ORIG_PATH"
  ORIG_PATH="$dateshim:$ORIG_PATH"
  run_inst "$log" "$home" --force
  ec1="$EC"
  run_inst "$work/log2" "$home" --force
  ec2="$EC"
  ORIG_PATH="$saved_path"
  rm -rf "$dateshim"
  cd "$saved_pwd"
  [ "$ec1" -eq 0 ] || note "first --force exit $ec1"
  [ "$ec2" -eq 0 ] || note "second --force exit $ec2"
  cmp -s "$work/rules.md.orig" "$rules" || note "project .skipr/rules.md changed"
  skills="$home/.claude/skills"
  nbak="$(find "$skills" -name '*bak*' 2>/dev/null | wc -l | tr -d ' ')"
  [ "$nbak" = "0" ] || note "bak entries under skills=$nbak want 0"
  broot="$home/.claude/skills-backup"
  nsetup=0
  nfdd=0
  : > "$work/suffixes"
  if [ -d "$broot" ]; then
    nsetup="$(find "$broot" -mindepth 1 -maxdepth 1 -type d -name 'setup-harness.*' | wc -l | tr -d ' ')"
    nfdd="$(find "$broot" -mindepth 1 -maxdepth 1 -type d -name 'fdd.*' | wc -l | tr -d ' ')"
    find "$broot" -mindepth 1 -maxdepth 1 -exec basename {} \; > "$work/backup-names"
    while IFS= read -r base; do
      case "$base" in
        *.*) printf '%s\n' "${base#*.}" ;;
        *) printf '%s\n' "$base" ;;
      esac
    done < "$work/backup-names" >> "$work/suffixes"
  fi
  [ "$nsetup" = "2" ] || note "setup-harness backups=$nsetup want 2"
  [ "$nfdd" = "2" ] || note "fdd backups=$nfdd want 2"
  nsuf="$(grep -c . "$work/suffixes" || true)"
  nuniq="$(sort "$work/suffixes" | uniq | grep -c . || true)"
  [ "$nsuf" = "4" ] && [ "$nuniq" = "4" ] || note "backup suffixes not distinct ($nuniq unique of $nsuf)"
  nested="$(find "$home/.claude" \( -path '*/setup-harness.*/setup-harness/SKILL.md' -o -path '*/fdd.*/fdd/SKILL.md' \) -print 2>/dev/null | head -n 1)"
  [ -z "$nested" ] || note "nested backup at $nested"
  # names must differ
  names="$(find "$broot" -mindepth 1 -maxdepth 1 -type d -name 'setup-harness.*' -exec basename {} \; 2>/dev/null | sort | uniq | wc -l | tr -d ' ')"
  [ "$names" = "2" ] || note "setup-harness backup names not distinct ($names)"
  : > "$work/skill-names"
  if [ -d "$skills" ]; then
    find "$skills" -name SKILL.md | sort > "$work/skill-files"
    while IFS= read -r skillf; do
      awk 'NR==1 && $0 != "---" { exit } NR>1 && $0 == "---" { exit } NR>1 && /^name:/ { sub(/^name:[ \t]*/, ""); gsub(/["\047]/, ""); print; exit }' "$skillf"
    done < "$work/skill-files" >> "$work/skill-names"
  fi
  nfdd_name="$(grep -cx 'fdd' "$work/skill-names" || true)"
  nsetup_name="$(grep -cx 'setup-harness' "$work/skill-names" || true)"
  dups="$(sort "$work/skill-names" | uniq -d | tr '\n' ' ')"
  [ "$nfdd_name" = "1" ] || note "fdd name count=$nfdd_name want 1"
  [ "$nsetup_name" = "1" ] || note "setup-harness name count=$nsetup_name want 1"
  [ -z "${dups% }" ] || note "duplicate skill names: ${dups% }"
  no_backup_under_skills "$home" || true
  finish 4
  rm -rf "$work"
}

# --- 5. backup restores hidden files, +x, and an internal symlink ---
begin 5
{
  work="$(new_home)"
  home="$work/home dir"
  log="$work/log"
  seed_skill "$REPO/skills/setup-harness" "$home/.claude/skills/setup-harness"
  seed_skill "$REPO/skills/fdd" "$home/.claude/skills/fdd"
  printf 'hidden\n' > "$home/.claude/skills/setup-harness/.hidden"
  chmod +x "$home/.claude/skills/setup-harness/SKILL.md"
  ln -s SKILL.md "$home/.claude/skills/setup-harness/alias-skill"
  snap="$work/snap-setup"
  rm -rf "$snap"
  cp -R "$home/.claude/skills/setup-harness" "$snap"
  run_inst "$log" "$home" --force
  [ "$EC" -eq 0 ] || note "exit $EC"
  broot="$home/.claude/skills-backup"
  setup_bak="$(find "$broot" -mindepth 1 -maxdepth 1 -type d -name 'setup-harness.*' 2>/dev/null | head -n 1)"
  if [ -z "$setup_bak" ]; then
    note "no setup-harness backup to restore"
  else
    rm -rf "$home/.claude/skills/setup-harness"
    mv "$setup_bak" "$home/.claude/skills/setup-harness"
    diff -rq "$snap" "$home/.claude/skills/setup-harness" >/dev/null || note "restored tree differs"
    [ -f "$home/.claude/skills/setup-harness/.hidden" ] || note "hidden file missing"
    [ -L "$home/.claude/skills/setup-harness/alias-skill" ] || note "internal symlink missing"
    [ "$(readlink "$home/.claude/skills/setup-harness/alias-skill")" = "SKILL.md" ] || note "symlink target changed"
    mode="$(stat -c %a "$home/.claude/skills/setup-harness/SKILL.md" 2>/dev/null || stat -f %OLp "$home/.claude/skills/setup-harness/SKILL.md")"
    case "$mode" in
      *755|*775|*777) : ;;
      *) note "executable bit not restored (mode $mode)" ;;
    esac
  fi
  no_backup_under_skills "$home" || true
  finish 5
  rm -rf "$work"
}

# --- 6. unreadable source file: no half-copied folder left ---
begin 6
{
  work="$(new_home)"
  home="$work/home dir"
  log="$work/log"
  src="$(mktemp -d)"
  git clone --local "$REPO" "$src/repo" >/dev/null 2>&1
  seed_skill "$src/repo/skills/setup-harness" "$home/.claude/skills/setup-harness"
  seed_skill "$src/repo/skills/fdd" "$home/.claude/skills/fdd"
  printf 'original\n' > "$home/.claude/skills/setup-harness/ORIGINAL.txt"
  printf 'original\n' > "$home/.claude/skills/fdd/ORIGINAL.txt"
  snap="$work/snap-setup"
  cp -R "$home/.claude/skills/setup-harness" "$snap"
  chmod 000 "$src/repo/skills/setup-harness/SKILL.md"
  EC=0
  env -u GIT_DIR -u GIT_WORK_TREE \
    HOME="$home" PATH="$ORIG_PATH" SKIPR_REPO_URL="$src/repo" \
    bash "$src/repo/scripts/install-macos.sh" --force </dev/null >"$log" 2>&1 || EC=$?
  [ "$EC" -ne 0 ] || note "expected non-zero exit"
  if diff -rq "$snap" "$home/.claude/skills/setup-harness" >/dev/null 2>&1; then
    :
  else
    bak=""
    orig="$(find "$home" -name ORIGINAL.txt -path '*setup-harness*' -print 2>/dev/null | head -n 1)"
    if [ -n "$orig" ]; then
      bak="$(cd "$(dirname "$orig")" && pwd)"
    fi
    if [ -n "$bak" ] && grep -F "$bak" "$log" >/dev/null 2>&1; then
      :
    else
      note "original is neither at dest nor in a backup named in the output"
    fi
  fi
  chmod 644 "$src/repo/skills/setup-harness/SKILL.md" 2>/dev/null || true
  EC=0
  env -u GIT_DIR -u GIT_WORK_TREE \
    HOME="$home" PATH="$ORIG_PATH" SKIPR_REPO_URL="$src/repo" \
    bash "$src/repo/scripts/install-macos.sh" </dev/null >"$work/log2" 2>&1 || EC=$?
  if diff -rq "$snap" "$home/.claude/skills/setup-harness" >/dev/null 2>&1 \
    || diff -rq "$src/repo/skills/setup-harness" "$home/.claude/skills/setup-harness" >/dev/null 2>&1; then
    :
  else
    note "next run kept a half-copied folder"
  fi
  half=""
  if [ -d "$home/.claude/skills" ]; then
    half="$(find "$home/.claude/skills" -mindepth 1 -type d -name '.*' -print 2>/dev/null | head -n 1)"
  fi
  [ -z "$half" ] || note "leftover partial dir $half"
  no_backup_under_skills "$home" || true
  finish 6
  chmod -R u+rwx "$src" 2>/dev/null || true
  rm -rf "$work" "$src"
}

# --- 7. symlink destination, --force does not modify the target ---
begin 7
{
  work="$(new_home)"
  home="$work/home dir"
  log="$work/log"
  mkdir -p "$home/targets/setup-harness" "$home/targets/fdd" "$home/.claude/skills"
  printf 'target-setup\n' > "$home/targets/setup-harness/MARKER.txt"
  printf 'target-fdd\n' > "$home/targets/fdd/MARKER.txt"
  ln -s "$home/targets/setup-harness" "$home/.claude/skills/setup-harness"
  ln -s "$home/targets/fdd" "$home/.claude/skills/fdd"
  snap_s="$work/snap-s"
  snap_f="$work/snap-f"
  cp -R "$home/targets/setup-harness" "$snap_s"
  cp -R "$home/targets/fdd" "$snap_f"
  run_inst "$log" "$home" --force
  [ "$EC" -eq 0 ] || note "exit $EC"
  diff -rq "$snap_s" "$home/targets/setup-harness" >/dev/null || note "setup-harness symlink target changed"
  diff -rq "$snap_f" "$home/targets/fdd" >/dev/null || note "fdd symlink target changed"
  no_backup_under_skills "$home" || true
  finish 7
  rm -rf "$work"
}

# --- 8. no local source (curl|bash path): both skills, temp clone removed ---
begin 8
{
  work="$(new_home)"
  home="$work/home dir"
  log="$work/log"
  tmp="$work/tmpdir"
  mkdir -p "$tmp"
  body="$(cat "$INSTALLER")"
  EC=0
  (
    cd "$work"
    env -u GIT_DIR -u GIT_WORK_TREE \
      HOME="$home" PATH="$ORIG_PATH" SKIPR_REPO_URL="$REPO" TMPDIR="$tmp" \
      bash -c "$body" bash </dev/null >"$log" 2>&1
  ) || EC=$?
  [ "$EC" -eq 0 ] || note "exit $EC"
  if [ -d "$home/.claude/skills/setup-harness" ]; then
    diff -rq "$REPO/skills/setup-harness" "$home/.claude/skills/setup-harness" >/dev/null || note "setup-harness differs"
  else
    note "setup-harness missing"
  fi
  if [ -d "$home/.claude/skills/fdd" ]; then
    diff -rq "$REPO/skills/fdd" "$home/.claude/skills/fdd" >/dev/null || note "fdd differs"
  else
    note "fdd missing"
  fi
  left="$(find "$tmp" -mindepth 1 -print 2>/dev/null | head -n 1)"
  [ -z "$left" ] || note "temp clone not removed ($left)"
  no_backup_under_skills "$home" || true
  finish 8
  rm -rf "$work"
}

# --- 9. mktemp failure: no copy outside HOME, original skill stays ---
begin 9
{
  work="$(new_home)"
  home="$work/home dir"
  log="$work/log"
  seed_skill "$REPO/skills/setup-harness" "$home/.claude/skills/setup-harness"
  seed_skill "$REPO/skills/fdd" "$home/.claude/skills/fdd"
  snap_s="$work/snap-setup"
  snap_f="$work/snap-fdd"
  cp -R "$home/.claude/skills/setup-harness" "$snap_s"
  cp -R "$home/.claude/skills/fdd" "$snap_f"
  printf 'canary\n' > "$work/canary"
  cplog="$work/cp.log"
  : > "$cplog"
  shim9="$(mktemp -d)"
  real_cp="$(command -v cp)"
  cat > "$shim9/mktemp" <<'EOF'
#!/bin/sh
exit 1
EOF
  cat > "$shim9/cp" <<EOF
#!/bin/sh
dest=""
for arg in "\$@"; do
  case "\$arg" in
    --) ;;
    -*) ;;
    *) dest=\$arg ;;
  esac
done
printf '%s\n' "\$dest" >> "\$SKIPR_CP_LOG"
case "\$dest" in
  "\$HOME"/*) exec '$real_cp' "\$@" ;;
esac
exit 1
EOF
  chmod +x "$shim9/mktemp" "$shim9/cp"
  EC=0
  env -u GIT_DIR -u GIT_WORK_TREE \
    HOME="$home" PATH="$shim9:$ORIG_PATH" SKIPR_REPO_URL="$REPO" SKIPR_CP_LOG="$cplog" \
    bash "$INSTALLER" --force </dev/null >"$log" 2>&1 || EC=$?
  rm -rf "$shim9"
  [ "$EC" -ne 0 ] || note "expected non-zero exit"
  if [ -d "$home/.claude/skills/setup-harness" ]; then
    diff -rq "$snap_s" "$home/.claude/skills/setup-harness" >/dev/null || note "setup-harness changed"
  else
    note "setup-harness missing"
  fi
  if [ -d "$home/.claude/skills/fdd" ]; then
    diff -rq "$snap_f" "$home/.claude/skills/fdd" >/dev/null || note "fdd changed"
  else
    note "fdd missing"
  fi
  outside="$(grep -v "^${home}/" "$cplog" 2>/dev/null || true)"
  [ -z "$outside" ] || note "copy outside HOME ($(printf '%s' "$outside" | tr '\n' ' '))"
  grep -qx 'canary' "$work/canary" || note "file outside HOME changed"
  finish 9
  rm -rf "$work"
}

# --- 10. clone-path mktemp -d fails: no clone, nothing written outside TMPDIR ---
begin 10
{
  work="$(new_home)"
  home="$work/home dir"
  log="$work/log"
  tmp="$work/tmpdir"
  gitlog="$work/git.log"
  mkdir -p "$tmp"
  printf 'canary\n' > "$work/canary"
  : > "$gitlog"
  shim10="$(mktemp -d)"
  real_mktemp="$(command -v mktemp)"
  real_git="$(command -v git)"
  cat > "$shim10/mktemp" <<EOF
#!/bin/sh
for arg in "\$@"; do
  case "\$arg" in
    *skipr-install*) exit 1 ;;
  esac
done
exec '$real_mktemp' "\$@"
EOF
  cat > "$shim10/git" <<EOF
#!/bin/sh
if [ "\${1:-}" = "clone" ]; then
  printf '%s\n' clone >> "\$SKIPR_GIT_LOG"
  exit 1
fi
exec '$real_git' "\$@"
EOF
  chmod +x "$shim10/mktemp" "$shim10/git"
  body="$(cat "$INSTALLER")"
  EC=0
  (
    cd "$work"
    env -u GIT_DIR -u GIT_WORK_TREE \
      HOME="$home" PATH="$shim10:$ORIG_PATH" SKIPR_REPO_URL="$REPO" \
      TMPDIR="$tmp" SKIPR_GIT_LOG="$gitlog" \
      bash -c "$body" bash </dev/null >"$log" 2>&1
  ) || EC=$?
  rm -rf "$shim10"
  [ "$EC" -ne 0 ] || note "expected non-zero exit"
  [ ! -s "$gitlog" ] || note "clone was attempted"
  outside="$(find "$work" -mindepth 1 \
    ! -path "$home" ! -path "$home/*" \
    ! -path "$tmp" ! -path "$tmp/*" \
    ! -path "$work/canary" ! -path "$work/log" ! -path "$work/git.log" \
    -print)"
  [ -z "$outside" ] || note "write outside the temp area"
  [ ! -e /skipr ] || note "clone destination /skipr exists"
  home_write="$(find "$home" -mindepth 1 -print | head -n 1)"
  [ -z "$home_write" ] || note "write outside the temp area ($home_write)"
  grep -qx 'canary' "$work/canary" || note "file outside the temp area changed"
  finish 10
  rm -rf "$work"
}

if [ "$fail" -eq 0 ]; then
  say "installer scenarios: PASS"
  exit 0
fi
say "installer scenarios: FAIL"
exit 1
