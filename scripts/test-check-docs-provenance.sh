#!/usr/bin/env bash
# A rule line that fails provenance must be reported as file:line only.
# The rule text is not printed. The term here is a fake stand-in.
set -u

root="$(cd "$(dirname "$0")/.." && pwd)"
src="$root/scripts/check-docs.sh"
term=qafaketerm
work="$(mktemp -d)"
mkdir -p "$work/scripts" "$work/.skipr"
cp "$src" "$work/scripts/check-docs.sh"
chmod +x "$work/scripts/check-docs.sh"
git -C "$work" init -q
git -C "$work" config user.email qa@example.invalid
git -C "$work" config user.name qa
printf 'ok\n' > "$work/README.md"
printf -- '- never use %s here\n' "$term" > "$work/.skipr/rules.md"
git -C "$work" add README.md scripts/check-docs.sh .skipr/rules.md
git -C "$work" commit -qm base
EC=0
OUT="$(cd "$work" && env -u CI -u GITHUB_ACTIONS DOCS_BANNED="$term" ./scripts/check-docs.sh 2>&1)" || EC=$?
rm -rf "$work"
fail=0
if [ "$EC" -ne 1 ]; then
  printf 'FAIL provenance exit %s want 1\n' "$EC"
  fail=1
fi
if printf '%s\n' "$OUT" | grep -qi "$term"; then
  printf 'FAIL provenance printed the term\n'
  fail=1
fi
if ! printf '%s\n' "$OUT" | grep -qE '^\.skipr/rules\.md:[0-9]+: rule line missing provenance$'; then
  printf 'FAIL provenance wanted file:line without the rule text\n'
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  printf 'provenance redaction: PASS\n'
  exit 0
fi
printf '%s\n' "$OUT"
printf 'provenance redaction: FAIL\n'
exit 1
