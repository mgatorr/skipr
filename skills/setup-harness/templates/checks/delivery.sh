#!/usr/bin/env bash
# Fail if entregables/ is missing, empty, or still has camera dump names.
set -euo pipefail
cd "$(dirname "$0")/.."
fail=0

if [[ ! -d entregables ]]; then
  echo "✗ Falta la carpeta entregables/"
  exit 1
fi

count=$(find entregables -type f ! -name '.DS_Store' | wc -l | tr -d ' ')
if [[ "$count" -lt 1 ]]; then
  echo "✗ entregables/ está vacía"
  exit 1
fi

while IFS= read -r -d '' f; do
  echo "✗ Nombre de cámara dentro de entregables/: $f"
  fail=1
done < <(find entregables -type f \( \
  -iname 'IMG_[0-9]*' -o -iname 'DSC_[0-9]*' -o -iname 'DSCF[0-9]*' \
\) -print0 2>/dev/null)

if [[ ! -f entregables/MANIFEST.md ]] && [[ ! -f MANIFEST.md ]]; then
  echo "✗ Falta MANIFEST.md (en entregables/ o en la raíz) con la lista de entrega"
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then
  echo
  echo "Prepara la entrega y vuelve a ejecutar ./checks/delivery.sh"
  exit 1
fi
echo "✓ delivery ok ($count ficheros)"
