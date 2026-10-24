#!/usr/bin/env bash
# Run setup-harness checkers against English and Spanish project fixtures.
set -u

root="$(cd "$(dirname "$0")/.." && pwd)"
checks="$root/skills/setup-harness/templates/checks"
photo_naming="$root/examples/photo-trip/checks/naming.sh"
fixtures="$root/skills/setup-harness/tests/fixtures"
fail=0

# Optional 5th argument: text the checker output must contain.
run_case() {
  local name="$1" expect="$2" checker="$3" src="$4" want="${5:-}"
  local work ec out has
  work="$(mktemp -d)"
  cp -R "$src"/. "$work"/
  mkdir -p "$work/checks"
  cp "$checker" "$work/checks/$(basename "$checker")"
  chmod +x "$work/checks/$(basename "$checker")"
  ec=0
  out="$(bash "$work/checks/$(basename "$checker")" 2>&1)" || ec=$?
  has=1
  case "$out" in *"$want"*) ;; *) has=0 ;; esac
  if [ "$ec" -eq "$expect" ] && [ "$has" -eq 1 ]; then
    printf 'PASS %s (exit %s)\n' "$name" "$ec"
  elif [ "$ec" -eq "$expect" ]; then
    printf 'FAIL %s output lacks: %s\n' "$name" "$want"
    printf '%s\n' "$out"
    fail=1
  else
    printf 'FAIL %s expected %s got %s\n' "$name" "$expect" "$ec"
    printf '%s\n' "$out"
    fail=1
  fi
  rm -rf "$work"
}

run_case brief-en 0 "$checks/brief-ready.sh" "$fixtures/brief-ready/en"
run_case brief-spanish-alias 0 "$checks/brief-ready.sh" "$fixtures/brief-ready/accepts-spanish-alias"
run_case brief-title-en 0 "$checks/brief-ready.sh" "$fixtures/brief-ready/title-en"
run_case brief-title-spanish-alias 0 "$checks/brief-ready.sh" "$fixtures/brief-ready/title-spanish-alias"
run_case brief-title-nospace 0 "$checks/brief-ready.sh" "$fixtures/brief-ready/title-nospace"
run_case brief-title-h2 0 "$checks/brief-ready.sh" "$fixtures/brief-ready/title-h2"
run_case brief-missing-date 1 "$checks/brief-ready.sh" "$fixtures/brief-ready/missing-date"
# The heading word is exact: "# Client notes" and "# Clientes: Acme Studio" are not titles.
run_case brief-loose-heading 1 "$checks/brief-ready.sh" "$fixtures/brief-ready/loose-heading"
run_case brief-rejects-client-plural 1 "$checks/brief-ready.sh" "$fixtures/brief-ready/rejects-client-plural"
run_case brief-not-prefix 1 "$checks/brief-ready.sh" "$fixtures/brief-ready/not-prefix"
# A required heading with nothing under it (blank lines until the next heading
# or the end) is an empty section, and the message names it.
run_case brief-empty-sections 1 "$checks/brief-ready.sh" "$fixtures/brief-ready/empty-sections" \
  "section «Client» / «Cliente» is empty"
run_case brief-empty-date 1 "$checks/brief-ready.sh" "$fixtures/brief-ready/empty-date" \
  "section «Date» / «Fecha» is empty"
run_case brief-empty-last-section 1 "$checks/brief-ready.sh" "$fixtures/brief-ready/empty-last-section" \
  "section «Deliverables» / «Entregables» is empty"
# Field style **Client:** Acme counts, with the same exact words; empty fails.
run_case brief-bold-fields-en 0 "$checks/brief-ready.sh" "$fixtures/brief-ready/bold-fields-en"
run_case brief-bold-fields-spanish 0 "$checks/brief-ready.sh" "$fixtures/brief-ready/bold-fields-spanish"
run_case brief-bold-empty 1 "$checks/brief-ready.sh" "$fixtures/brief-ready/bold-empty" \
  "section «Client» / «Cliente» is empty"
run_case brief-bold-loose 1 "$checks/brief-ready.sh" "$fixtures/brief-ready/bold-loose" \
  "missing heading «Client» or «Cliente»"
# "Delivery date" and "Fecha de entrega" are the date heading too.
run_case brief-delivery-date-en 0 "$checks/brief-ready.sh" "$fixtures/brief-ready/delivery-date-en"
run_case brief-delivery-date-spanish 0 "$checks/brief-ready.sh" "$fixtures/brief-ready/delivery-date-spanish"

run_case naming-en 0 "$checks/naming.sh" "$fixtures/naming/en"
run_case naming-spanish-alias 0 "$checks/naming.sh" "$fixtures/naming/accepts-spanish-alias"
run_case naming-en-working-folders 0 "$checks/naming.sh" "$fixtures/naming/en-working-folders"
run_case naming-spanish-working-folders 0 "$checks/naming.sh" "$fixtures/naming/spanish-working-folders"
run_case naming-undated 1 "$checks/naming.sh" "$fixtures/naming/undated"
run_case naming-loose 1 "$checks/naming.sh" "$fixtures/naming/loose"
run_case naming-photo-trip-en 0 "$photo_naming" "$fixtures/naming/en"
run_case naming-photo-trip-spanish-alias 0 "$photo_naming" "$fixtures/naming/accepts-spanish-alias"
run_case naming-photo-trip-spanish-working-folders 0 "$photo_naming" "$fixtures/naming/spanish-working-folders"

# Camera default names beyond IMG_: Sony, Nikon, DJI, GoPro, Fuji, Canon, any case.
# The template and the photo-trip copy must agree, and delivery.sh must agree too.
camera_cases="sony-dsc nikon-dsc nikon-underscore dji dji-timestamp gopro gopro-hero fuji canon dji-lowercase"
for c in $camera_cases; do
  run_case "naming-camera-$c" 1 "$checks/naming.sh" "$fixtures/naming/camera-$c" \
    "Loose camera dump name at project root"
  run_case "naming-photo-trip-camera-$c" 1 "$photo_naming" "$fixtures/naming/camera-$c" \
    "Loose camera dump name at project root"
  run_case "delivery-camera-$c" 1 "$checks/delivery.sh" "$fixtures/delivery/camera-$c" \
    "Camera dump name inside deliverables/"
done
# Words like "dji" or "gopro" inside a real name are not camera dumps.
run_case naming-similar-names 0 "$checks/naming.sh" "$fixtures/naming/similar-names"
run_case naming-photo-trip-similar-names 0 "$photo_naming" "$fixtures/naming/similar-names"
run_case delivery-similar-names 0 "$checks/delivery.sh" "$fixtures/delivery/similar-names"

run_case delivery-en 0 "$checks/delivery.sh" "$fixtures/delivery/en"
run_case delivery-spanish-alias 0 "$checks/delivery.sh" "$fixtures/delivery/accepts-spanish-alias"
run_case delivery-camera 1 "$checks/delivery.sh" "$fixtures/delivery/camera"
# MANIFEST.md alone is not a delivery: something besides the manifest must ship.
run_case delivery-manifest-only 1 "$checks/delivery.sh" "$fixtures/delivery/manifest-only" \
  "nothing to deliver besides MANIFEST.md"
run_case delivery-manifest-only-spanish 1 "$checks/delivery.sh" "$fixtures/delivery/manifest-only-spanish" \
  "entregables/ has nothing to deliver besides MANIFEST.md"

if [ "$fail" -eq 0 ]; then
  printf 'harness checks: PASS\n'
  exit 0
fi
printf 'harness checks: FAIL\n'
exit 1
