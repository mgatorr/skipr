#!/usr/bin/env bash
# Fail if deliverables/ is missing, empty, or has camera dump names.
set -euo pipefail
cd "$(dirname "$0")/.."

fail=0

if [[ ! -d deliverables ]]; then
  echo "✗ Missing deliverables/ folder"
  exit 1
fi

count=$(find deliverables -type f ! -name '.DS_Store' | wc -l | tr -d ' ')
if [[ "$count" -lt 1 ]]; then
  echo "✗ deliverables/ is empty"
  exit 1
fi

while IFS= read -r -d '' f; do
  echo "✗ Camera dump name inside deliverables/: $f"
  fail=1
done < <(find deliverables -type f \( \
  -iname 'IMG_[0-9]*' -o -iname 'DSC_[0-9]*' -o -iname 'DSCF[0-9]*' \
\) -print0 2>/dev/null)

if [[ ! -f deliverables/MANIFEST.md ]] && [[ ! -f MANIFEST.md ]]; then
  echo "✗ Missing MANIFEST.md (in deliverables/ or project root) listing the delivery"
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then
  echo
  echo "Prepare the delivery and re-run ./checks/delivery.sh"
  exit 1
fi
echo "✓ delivery ok ($count files)"
