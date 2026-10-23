#!/usr/bin/env bash
# Step 4 of the README, pasted from the project folder, must install the skill
# and must not report success when the copy fails.
set -u

root="$(cd "$(dirname "$0")/.." && pwd)"
trap 'export HOME=/home/ubuntu' EXIT
fail=0
say() { printf '%s\n' "$*"; }
note() { say "FAIL $*"; fail=1; }

block="$(python3 - "$root/README.md" <<'PY'
import re, sys
t = open(sys.argv[1]).read()
want = "cp -R skills/setup-harness"
for m in re.finditer(r"```bash\n(.*?)```", t, re.S):
    if want in m.group(1):
        print(m.group(1))
        break
PY
)"
block="$(printf '%s\n' "$block" | grep -vE '^[[:space:]]*claude[[:space:]]*$' || true)"
if [ -z "$block" ]; then
  note "step 4 block not found"
  say "readme step 4: FAIL"
  exit 1
fi

work="$(mktemp -d)"
export HOME="$work/home"
mkdir -p "$HOME/skipr/skills" "$HOME/Projects/lisbon-trip"
cp -R "$root/skills/setup-harness" "$HOME/skipr/skills/setup-harness"
ec=0
(
  cd "$HOME/Projects/lisbon-trip"
  bash -c "$block"
) >"$work/log" 2>&1 || ec=$?
if [ "$ec" -ne 0 ]; then
  note "step 4 from the project folder exit $ec"
fi
if [ ! -f "$HOME/.claude/skills/setup-harness/SKILL.md" ]; then
  note "setup-harness was not installed"
fi
# A missing source must fail the block, not fall through to the final cd.
rm -rf "$HOME/.claude" "$HOME/skipr/skills"
ec2=0
(
  cd "$HOME/Projects/lisbon-trip"
  bash -c "$block"
) >"$work/log2" 2>&1 || ec2=$?
if [ "$ec2" -eq 0 ]; then
  note "missing source still exited 0"
fi
rm -rf "$work"
unset HOME
export HOME=/home/ubuntu

if [ "$fail" -eq 0 ]; then
  say "readme step 4: PASS"
  exit 0
fi
say "readme step 4: FAIL"
exit 1
