#!/usr/bin/env bash
# Fail if BRIEF.md is missing or missing required sections.
set -euo pipefail
cd "$(dirname "$0")/.."

# Locale: English default; Spanish when Working language / SKIPR_LOCALE / LANG is es
_loc="${SKIPR_LOCALE:-${LANG:-en}}"
_loc="${_loc%%_*}"
_loc="${_loc%%.*}"
_loc="$(printf '%s' "$_loc" | tr '[:upper:]' '[:lower:]')"
ES=0
[[ "$_loc" == es* ]] && ES=1

fail=0

if [[ ! -f BRIEF.md ]]; then
  if [[ "$ES" -eq 1 ]]; then
    echo "✗ Falta BRIEF.md en la raíz del proyecto"
    echo "  Crea uno con: Cliente, Fecha, Entregables, tono/uso."
  else
    echo "✗ Missing BRIEF.md at project root"
    echo "  Create one with: Client, Date, Deliverables, tone/use."
  fi
  exit 1
fi

# Accept EN headings (canonical) or legacy ES headings
for pair in "Client|Cliente" "Date|Fecha" "Deliverables|Entregables"; do
  en="${pair%%|*}"
  es="${pair##*|}"
  if ! grep -qiE "^#+[[:space:]]*($en|$es)" BRIEF.md; then
    if [[ "$ES" -eq 1 ]]; then
      echo "✗ BRIEF.md no tiene sección «$en» / «$es»"
    else
      echo "✗ BRIEF.md is missing heading «$en» (or legacy «$es»)"
    fi
    fail=1
  fi
done

lines=$(grep -cve '^[[:space:]]*$' BRIEF.md || true)
if [[ "$lines" -lt 4 ]]; then
  if [[ "$ES" -eq 1 ]]; then
    echo "✗ BRIEF.md está casi vacío ($lines líneas con texto)"
  else
    echo "✗ BRIEF.md is nearly empty ($lines non-empty lines)"
  fi
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then
  echo
  if [[ "$ES" -eq 1 ]]; then
    echo "Completa BRIEF.md y vuelve a ejecutar ./checks/brief-ready.sh"
  else
    echo "Complete BRIEF.md and re-run ./checks/brief-ready.sh"
  fi
  exit 1
fi
echo "✓ brief ok"
