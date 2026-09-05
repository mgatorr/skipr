#!/usr/bin/env bash
# Fail if deliverables/ (or legacy entregables/) is missing, empty, or has camera dump names.
set -euo pipefail
cd "$(dirname "$0")/.."

_loc="${SKIPR_LOCALE:-${LANG:-en}}"
_loc="${_loc%%_*}"
_loc="${_loc%%.*}"
_loc="$(printf '%s' "$_loc" | tr '[:upper:]' '[:lower:]')"
ES=0
[[ "$_loc" == es* ]] && ES=1

fail=0

DELIV_DIR=""
if [[ -d deliverables ]]; then
  DELIV_DIR=deliverables
elif [[ -d entregables ]]; then
  DELIV_DIR=entregables
fi

if [[ -z "$DELIV_DIR" ]]; then
  if [[ "$ES" -eq 1 ]]; then
    echo "✗ Falta la carpeta deliverables/ (o legacy entregables/)"
  else
    echo "✗ Missing deliverables/ folder (legacy entregables/ also accepted)"
  fi
  exit 1
fi

count=$(find "$DELIV_DIR" -type f ! -name '.DS_Store' | wc -l | tr -d ' ')
if [[ "$count" -lt 1 ]]; then
  if [[ "$ES" -eq 1 ]]; then
    echo "✗ $DELIV_DIR/ está vacía"
  else
    echo "✗ $DELIV_DIR/ is empty"
  fi
  exit 1
fi

while IFS= read -r -d '' f; do
  if [[ "$ES" -eq 1 ]]; then
    echo "✗ Nombre de cámara dentro de $DELIV_DIR/: $f"
  else
    echo "✗ Camera dump name inside $DELIV_DIR/: $f"
  fi
  fail=1
done < <(find "$DELIV_DIR" -type f \( \
  -iname 'IMG_[0-9]*' -o -iname 'DSC_[0-9]*' -o -iname 'DSCF[0-9]*' \
\) -print0 2>/dev/null)

if [[ ! -f "$DELIV_DIR/MANIFEST.md" ]] && [[ ! -f MANIFEST.md ]]; then
  if [[ "$ES" -eq 1 ]]; then
    echo "✗ Falta MANIFEST.md (en $DELIV_DIR/ o en la raíz) con la lista de entrega"
  else
    echo "✗ Missing MANIFEST.md (in $DELIV_DIR/ or project root) listing the delivery"
  fi
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then
  echo
  if [[ "$ES" -eq 1 ]]; then
    echo "Prepara la entrega y vuelve a ejecutar ./checks/delivery.sh"
  else
    echo "Prepare the delivery and re-run ./checks/delivery.sh"
  fi
  exit 1
fi
echo "✓ delivery ok ($count files)"
