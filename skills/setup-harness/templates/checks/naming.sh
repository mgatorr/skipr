#!/usr/bin/env bash
# Fail if loose camera dump names or undated top-level folders show up.
set -euo pipefail
cd "$(dirname "$0")/.."
fail=0

# Loose IMG_/DSC_/RAW camera names at project root
while IFS= read -r -d '' f; do
  echo "✗ Nombre de cámara suelto en la raíz: $f"
  fail=1
done < <(find . -maxdepth 1 -type f \( \
  -iname 'IMG_[0-9]*' -o -iname 'DSC_[0-9]*' -o -iname 'DSCF[0-9]*' \
  -o -iname '_MG_[0-9]*' -o -iname 'P[0-9][0-9][0-9][0-9]*' \
\) -print0 2>/dev/null)

# Top-level dirs that look like media dumps without a date prefix
while IFS= read -r -d '' d; do
  base=$(basename "$d")
  case "$base" in
    .|.claude|checks|entregables|selects|rejects|raw|jpg|jpeg|preview|edits) continue ;;
  esac
  if ! [[ "$base" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2} ]]; then
    # Only flag if the dir contains image-like files
    if find "$d" -maxdepth 2 -type f \( \
      -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.raf' -o -iname '*.cr2' \
      -o -iname '*.cr3' -o -iname '*.nef' -o -iname '*.arw' -o -iname '*.dng' \
      -o -iname '*.heic' \
    \) -print -quit | grep -q .; then
      echo "✗ Carpeta con fotos sin prefijo de fecha YYYY-MM-DD: $base"
      fail=1
    fi
  fi
done < <(find . -maxdepth 1 -type d ! -name '.' -print0 2>/dev/null)

if [[ "$fail" -ne 0 ]]; then
  echo
  echo "Arregla naming (renombra; no borres) y vuelve a ejecutar ./checks/naming.sh"
  exit 1
fi
echo "✓ naming ok"
