#!/usr/bin/env bash
# claude in the README install block runs only after that block succeeds.
# A missing ~/skipr means the clone did not succeed; the stub must not run.
set -u

root="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
say() { printf '%s\n' "$*"; }
note() { say "FAIL $*"; fail=1; }

block="$(python3 - "$root/README.md" <<'PY'
import re, sys
text = open(sys.argv[1]).read()
for m in re.finditer(r"```bash\n(.*?)```", text, re.S):
    body = m.group(1)
    if "claude" in body and "setup-harness" in body:
        print(body)
        break
PY
)"
if [ -z "$block" ]; then
  note "install block with claude was not found"
  say "readme claude: FAIL"
  exit 1
fi

work="$(mktemp -d)"
cleanup() { rm -rf "$work"; }
trap cleanup EXIT

mkdir -p "$work/bin"
cat > "$work/bin/claude" <<EOF
#!/bin/sh
touch "$work/claude.invoked"
EOF
chmod +x "$work/bin/claude"

run_block() {
  local home="$1" marker="$2"
  rm -f "$marker"
  (
    cd "$home"
    PATH="$work/bin:$PATH" HOME="$home" \
      bash -c "$block"
  ) >"$work/run.out" 2>"$work/run.err" || true
}

# Clone did not succeed: ~/skipr is absent, so cd ~/skipr fails.
mkdir -p "$work/failhome"
run_block "$work/failhome" "$work/claude.invoked"
if [ -f "$work/claude.invoked" ]; then
  note "claude ran after the clone directory was missing"
fi

# The same block starts claude when the clone is present.
mkdir -p "$work/okhome/skipr/skills" "$work/okhome/Projects/lisbon-trip"
cp -R "$root/skills/setup-harness" "$work/okhome/skipr/skills/setup-harness"
run_block "$work/okhome" "$work/claude.invoked"
if [ ! -f "$work/claude.invoked" ]; then
  note "claude did not run when the clone was present"
fi

if [ "$fail" -eq 0 ]; then
  say "readme claude: PASS"
  exit 0
fi
say "readme claude: FAIL"
exit 1
