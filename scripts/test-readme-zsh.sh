#!/usr/bin/env bash
# Pasted README blocks are fed to interactive zsh. zsh does not treat "#" as a
# comment unless interactivecomments is on, so a comment line runs as a command
# and "# or ..." becomes arguments.
set -u

root="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
say() { printf '%s\n' "$*"; }
note() { say "FAIL $*"; fail=1; }

if ! command -v zsh >/dev/null 2>&1; then
  note "zsh is not installed"
  say "readme zsh: FAIL"
  exit 1
fi

work="$(mktemp -d)"
cleanup() { rm -rf "$work"; }
trap cleanup EXIT

python3 - "$root/README.md" "$work" <<'PY'
import pathlib, re, sys
readme, dest = sys.argv[1], pathlib.Path(sys.argv[2])
text = pathlib.Path(readme).read_text()
blocks = re.findall(r"```bash\n(.*?)```", text, re.S)
if not blocks:
    sys.exit("no bash blocks")
for i, block in enumerate(blocks):
    (dest / f"block-{i}").write_text(block)
PY

stub="$work/bin"
mkdir -p "$stub" "$work/home" "$work/cwd/checks"
cat > "$stub/git" <<'EOF'
#!/bin/sh
if [ "${1:-}" = clone ]; then
  echo "stub clone" >&2
  exit 1
fi
exit 0
EOF
cat > "$stub/claude" <<'EOF'
#!/bin/sh
exit 0
EOF
cat > "$work/cwd/checks/naming.sh" <<EOF
#!/bin/sh
printf '%s\n' "\$#" > "$work/naming.args"
printf '%s\n' "\$@" >> "$work/naming.args"
EOF
chmod +x "$stub/git" "$stub/claude" "$work/cwd/checks/naming.sh"

say "readme zsh: using $(zsh --version)"

for block in "$work"/block-*; do
  if grep -qE '^[[:space:]]*#' "$block"; then
    note "pasted block has a comment line ($(basename "$block"))"
  fi
  PATH="$stub:$PATH" HOME="$work/home" \
    zsh -f -i +o interactivecomments \
    <"$block" >"$work/zsh.out" 2>"$work/zsh.err" || true
  if grep -q 'command not found: #' "$work/zsh.err"; then
    note "zsh tried to run a hash comment ($(basename "$block"))"
  fi
done

# Run from the stub project so ./checks/naming.sh is the recorder.
# Only the step-5 block is a single naming.sh command; step 0 cds away first.
: > "$work/naming.args"
for block in "$work"/block-*; do
  grep -q 'naming\.sh' "$block" || continue
  if grep -qE '^[[:space:]]*cd[[:space:]]' "$block"; then
    continue
  fi
  (
    cd "$work/cwd"
    PATH="$stub:$PATH" HOME="$work/home" \
      zsh -f -i +o interactivecomments \
      <"$block" >"$work/step5.out" 2>"$work/step5.err" || true
  )
  if grep -qx '#' "$work/naming.args" || grep -qx 'or' "$work/naming.args"; then
    note "naming.sh received a hash or or token ($(basename "$block"))"
  fi
done

if [ "$fail" -eq 0 ]; then
  say "readme zsh: PASS"
  exit 0
fi
say "readme zsh: FAIL"
exit 1
