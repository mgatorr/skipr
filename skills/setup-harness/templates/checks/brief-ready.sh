#!/usr/bin/env bash
# Fail if BRIEF.md is missing or missing required sections.
set -euo pipefail
cd "$(dirname "$0")/.."

fail=0

if [[ ! -f BRIEF.md ]]; then
  echo "✗ Missing BRIEF.md at project root"
  echo "  Create one with: Client or Cliente, Date or Fecha, Deliverables or Entregables, tone/use."
  exit 1
fi

for pair in "Client|Cliente" "Date|Fecha" "Deliverables|Entregables"; do
  en="${pair%%|*}"
  es="${pair##*|}"
  if ! grep -qiE "^#+[[:space:]]*(${en}|${es})[[:space:]]*$" BRIEF.md; then
    echo "✗ BRIEF.md is missing heading «${en}» or «${es}»"
    fail=1
  fi
done

lines=$(grep -cve '^[[:space:]]*$' BRIEF.md || true)
if [[ "$lines" -lt 4 ]]; then
  echo "✗ BRIEF.md is nearly empty ($lines non-empty lines)"
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then
  echo
  echo "Complete BRIEF.md and re-run ./checks/brief-ready.sh"
  exit 1
fi
echo "✓ brief ok"
