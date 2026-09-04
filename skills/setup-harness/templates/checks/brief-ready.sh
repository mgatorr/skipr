#!/usr/bin/env bash
# Fail if BRIEF.md is missing or missing required sections.
set -euo pipefail
cd "$(dirname "$0")/.."
fail=0

if [[ ! -f BRIEF.md ]]; then
  echo "✗ Falta BRIEF.md en la raíz del proyecto"
  echo "  Crea uno con: cliente, fecha, entregables, tono/uso."
  exit 1
fi

for heading in "Cliente" "Fecha" "Entregables"; do
  if ! grep -qiE "^#+[[:space:]]*$heading" BRIEF.md; then
    echo "✗ BRIEF.md no tiene sección «$heading»"
    fail=1
  fi
done

# Empty body check (less than 4 non-empty lines)
lines=$(grep -cve '^[[:space:]]*$' BRIEF.md || true)
if [[ "$lines" -lt 4 ]]; then
  echo "✗ BRIEF.md está casi vacío ($lines líneas con texto)"
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then
  echo
  echo "Completa BRIEF.md y vuelve a ejecutar ./checks/brief-ready.sh"
  exit 1
fi
echo "✓ brief ok"
