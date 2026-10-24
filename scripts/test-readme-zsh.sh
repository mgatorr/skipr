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

# The guides are pasted too. Their blocks are not run here (they clone, cd and
# install), so a "#" line in any bash/sh/zsh fence fails on sight. Put the
# words in the prose next to the block instead.
if ! python3 - "$root" <<'PY'
import pathlib, re, sys
root = pathlib.Path(sys.argv[1])
docs = ["README.md", "docs/novice-guide.md", "docs/for-photographers.md", "scripts/README.md"]
fence = re.compile(r"^[ \t]*```(?:bash|sh|zsh)[ \t]*\n(.*?)^[ \t]*```", re.S | re.M)
bad = 0
for doc in docs:
    text = (root / doc).read_text()
    blocks = fence.findall(text)
    if not blocks:
        print(f"FAIL no shell blocks found in {doc}")
        bad = 1
    for i, body in enumerate(blocks):
        for line in body.splitlines():
            # A trailing "  # note" is a comment too; quoted text is not.
            bare = re.sub(r"'[^']*'|\"(?:\\.|[^\"\\])*\"", "", line)
            if re.search(r"(^|[ \t])#", bare):
                print(f"FAIL pasted block has a comment ({doc} block {i}): {line.strip()}")
                bad = 1
sys.exit(bad)
PY
then
  fail=1
fi

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

# Skill copy blocks: README, the guides, and the fallback the installer prints.
# Pasted from the wrong folder they must leave the existing skill in place.
# With ~/.claude/skills-backup a file they must not nest skill/skill.
copies="$work/copies"
mkdir -p "$copies"
if ! python3 - "$root" "$copies" <<'PY'
import pathlib, re, sys
root, dest = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
n = 0
def keep(name, body):
    global n
    skills = sorted(set(re.findall(r"cp -R \S*skills/([a-z-]+) ~/\.claude/skills/", body)))
    if not skills:
        return
    (dest / f"copy-{n}").write_text(body + "\n")
    (dest / f"copy-{n}.skills").write_text("\n".join(skills) + "\n")
    (dest / f"copy-{n}.name").write_text(name + "\n")
    n += 1
for doc in ["README.md", "docs/novice-guide.md", "docs/for-photographers.md"]:
    text = (root / doc).read_text()
    for i, m in enumerate(re.finditer(r"```bash\n(.*?)```", text, re.S)):
        keep(f"{doc} block {i}", m.group(1))
lines = (root / "scripts/install-macos.sh").read_text().splitlines()
start = next(i for i, l in enumerate(lines) if "copy manually:" in l)
end = next(i for i in range(start, len(lines)) if lines[i] == "EOF")
body = "\n".join(l[6:] if l.startswith("      ") else l.strip() for l in lines[start + 1:end])
body = body.replace("\\$", "$").replace("${SKIPR_REPO_URL}", "https://example.invalid/skipr.git")
keep("install-macos.sh manual fallback", body)
if n < 6:
    sys.exit(f"only {n} skill copy blocks found")
PY
then
  note "skill copy blocks not extracted"
fi

seed_home() {
  local home="$1" clone="$2" s
  rm -rf "$home"
  mkdir -p "$home/Projects/lisbon-trip" "$home/elsewhere"
  if [ "$clone" = yes ]; then
    mkdir -p "$home/skipr/skills"
    cp -R "$root/skills/setup-harness" "$root/skills/fdd" "$home/skipr/skills/"
  fi
  while IFS= read -r s; do
    mkdir -p "$home/.claude/skills/$s"
    printf 'old\n' > "$home/.claude/skills/$s/OLD"
  done < "$skills"
}

paste_block() {
  local home="$1" cwd="$2"
  (
    cd "$cwd"
    { cat "$copy"; printf '%s\n' 'false' 'echo alive'; } |
      PATH="$stub:$PATH" HOME="$home" zsh -f -i +o interactivecomments \
      >"$work/copy.out" 2>"$work/copy.err" || true
  )
}

for copy in "$copies"/copy-?; do
  [ -f "$copy" ] || continue
  skills="$copy.skills"
  name="$(cat "$copy.name")"
  h="$work/copyhome"

  # Wrong folder, no clone: nothing may be moved away.
  seed_home "$h" no
  paste_block "$h" "$h/elsewhere"
  while IFS= read -r s; do
    [ -f "$h/.claude/skills/$s/OLD" ] || note "$name from a wrong folder removed the existing $s"
  done < "$skills"
  grep -qx 'alive' "$work/copy.out" || note "$name closed the shell"

  # skills-backup is a file, pasted inside the clone: no nesting, old skill stays.
  seed_home "$h" yes
  printf 'not a dir\n' > "$h/.claude/skills-backup"
  paste_block "$h" "$h/skipr"
  while IFS= read -r s; do
    [ ! -e "$h/.claude/skills/$s/$s" ] || note "$name nested $s/$s with skills-backup a file"
    [ -f "$h/.claude/skills/$s/OLD" ] || note "$name lost the existing $s with skills-backup a file"
  done < "$skills"

  # From the project folder with the clone at ~/skipr: installs, old copy aside.
  seed_home "$h" yes
  paste_block "$h" "$h/Projects/lisbon-trip"
  while IFS= read -r s; do
    [ -f "$h/.claude/skills/$s/SKILL.md" ] || note "$name did not install $s"
    [ ! -e "$h/.claude/skills/$s/OLD" ] || note "$name left the old $s in place"
    ls "$h/.claude/skills-backup/$s".* >/dev/null 2>&1 || note "$name made no backup of $s"
  done < "$skills"
  rm -rf "$h"
done

if [ "$fail" -eq 0 ]; then
  say "readme zsh: PASS"
  exit 0
fi
say "readme zsh: FAIL"
exit 1
