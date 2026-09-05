#!/usr/bin/env bash
# Fail if loose camera dump names or undated top-level folders show up.
set -euo pipefail
cd "$(dirname "$0")/.."

_loc="${SKIPR_LOCALE:-${LANG:-en}}"
_loc="${_loc%%_*}"
_loc="${_loc%%.*}"
_loc="$(printf '%s' "$_loc" | tr '[:upper:]' '[:lower:]')"
ES=0
[[ "$_loc" == es* ]] && ES=1

fail=0

while IFS= read -r -d '' f; do
  if [[ "$ES" -eq 1 ]]; then
    echo "✗ Nombre de cámara suelto en la raíz: $f"
  else
    echo "✗ Loose camera dump name at project root: $f"
  fi
  fail=1
done < <(find . -maxdepth 1 -type f \( \
  -iname 'IMG_[0-9]*' -o -iname 'DSC_[0-9]*' -o -iname 'DSCF[0-9]*' \
  -o -iname '_MG_[0-9]*' -o -iname 'P[0-9][0-9][0-9][0-9]*' \
\) -print0 2>/dev/null)

while IFS= read -r -d '' d; do
  base=$(basename "$d")
  case "$base" in
    .|.claude|checks|entregables|deliverables|selects|rejects|raw|jpg|jpeg|preview|edits) continue ;;
  esac
  if ! [[ "$base" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2} ]]; then
    if find "$d" -maxdepth 2 -type f \( \
      -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.raf' -o -iname '*.cr2' \
      -o -iname '*.cr3' -o -iname '*.nef' -o -iname '*.arw' -o -iname '*.dng' \
      -o -iname '*.heic' \
    \) -print -quit | grep -q .; then
      if [[ "$ES" -eq 1 ]]; then
        echo "✗ Carpeta con fotos sin prefijo de fecha YYYY-MM-DD: $base"
      else
        echo "✗ Photo folder missing YYYY-MM-DD date prefix: $base"
      fi
      fail=1
    fi
  fi
done < <(find . -maxdepth 1 -type d ! -name '.' -print0 2>/dev/null)

if [[ "$fail" -ne 0 ]]; then
  echo
  if [[ "$ES" -eq 1 ]]; then
    echo "Arregla naming (renombra; no borres) y vuelve a ejecutar ./checks/naming.sh"
  else
    echo "Fix naming (rename; do not delete) and re-run ./checks/naming.sh"
  fi
  exit 1
fi
echo "✓ naming ok"
