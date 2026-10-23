#!/usr/bin/env bash
# Run setup-harness checkers against English and Spanish project fixtures.
set -u

root="$(cd "$(dirname "$0")/.." && pwd)"
checks="$root/skills/setup-harness/templates/checks"
photo_naming="$root/examples/photo-trip/checks/naming.sh"
fixtures="$root/skills/setup-harness/tests/fixtures"
fail=0

run_case() {
  local name="$1" expect="$2" checker="$3" src="$4"
  local work ec out
  work="$(mktemp -d)"
  cp -R "$src"/. "$work"/
  mkdir -p "$work/checks"
  cp "$checker" "$work/checks/$(basename "$checker")"
  chmod +x "$work/checks/$(basename "$checker")"
  ec=0
  out="$(bash "$work/checks/$(basename "$checker")" 2>&1)" || ec=$?
  if [ "$ec" -eq "$expect" ]; then
    printf 'PASS %s (exit %s)\n' "$name" "$ec"
  else
    printf 'FAIL %s expected %s got %s\n' "$name" "$expect" "$ec"
    printf '%s\n' "$out"
    fail=1
  fi
  rm -rf "$work"
}

run_case brief-en 0 "$checks/brief-ready.sh" "$fixtures/brief-ready/en"
run_case brief-es 0 "$checks/brief-ready.sh" "$fixtures/brief-ready/es"
run_case brief-title-en 0 "$checks/brief-ready.sh" "$fixtures/brief-ready/title-en"
run_case brief-title-es 0 "$checks/brief-ready.sh" "$fixtures/brief-ready/title-es"
run_case brief-missing-date 1 "$checks/brief-ready.sh" "$fixtures/brief-ready/missing-date"
run_case brief-loose-heading 1 "$checks/brief-ready.sh" "$fixtures/brief-ready/loose-heading"
run_case brief-not-prefix 1 "$checks/brief-ready.sh" "$fixtures/brief-ready/not-prefix"

run_case naming-en 0 "$checks/naming.sh" "$fixtures/naming/en"
run_case naming-es 0 "$checks/naming.sh" "$fixtures/naming/es"
run_case naming-undated 1 "$checks/naming.sh" "$fixtures/naming/undated"
run_case naming-loose 1 "$checks/naming.sh" "$fixtures/naming/loose"
run_case naming-photo-trip-en 0 "$photo_naming" "$fixtures/naming/en"
run_case naming-photo-trip-es 0 "$photo_naming" "$fixtures/naming/es"

run_case delivery-en 0 "$checks/delivery.sh" "$fixtures/delivery/en"
run_case delivery-es 0 "$checks/delivery.sh" "$fixtures/delivery/es"
run_case delivery-camera 1 "$checks/delivery.sh" "$fixtures/delivery/camera"

if [ "$fail" -eq 0 ]; then
  printf 'harness checks: PASS\n'
  exit 0
fi
printf 'harness checks: FAIL\n'
exit 1
