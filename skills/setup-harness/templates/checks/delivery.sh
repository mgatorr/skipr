#!/usr/bin/env bash
# Fail if deliverables/ (or entregables/) is missing, empty, or has camera dump names.
set -euo pipefail
cd "$(dirname "$0")/.."

fail=0

DELIV_DIR=""
if [[ -d deliverables ]]; then
  DELIV_DIR=deliverables
elif [[ -d entregables ]]; then
  DELIV_DIR=entregables
fi

if [[ -z "$DELIV_DIR" ]]; then
  echo "✗ Missing deliverables/ folder (entregables/ also accepted)"
  exit 1
fi

count=$(find "$DELIV_DIR" -type f ! -name '.DS_Store' | wc -l | tr -d ' ')
if [[ "$count" -lt 1 ]]; then
  echo "✗ ${DELIV_DIR}/ is empty"
  exit 1
fi

while IFS= read -r -d '' f; do
  echo "✗ Camera dump name inside ${DELIV_DIR}/: $f"
  fail=1
done < <(find "$DELIV_DIR" -type f \( \
  -iname 'IMG_[0-9]*' -o -iname 'DSC_[0-9]*' -o -iname 'DSCF[0-9]*' \
\) -print0 2>/dev/null)

if [[ ! -f "$DELIV_DIR/MANIFEST.md" ]] && [[ ! -f MANIFEST.md ]]; then
  echo "✗ Missing MANIFEST.md (in ${DELIV_DIR}/ or project root) listing the delivery"
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then
  echo
  echo "Prepare the delivery and re-run ./checks/delivery.sh"
  exit 1
fi
echo "✓ delivery ok ($count files)"
