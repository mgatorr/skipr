#!/usr/bin/env bash
# Fail if BRIEF.md is missing, misses a required section, or a required section is empty.
set -euo pipefail
cd "$(dirname "$0")/.."

fail=0

if [[ ! -f BRIEF.md ]]; then
  echo "✗ Missing BRIEF.md at project root"
  echo "  Create one with: Client or Cliente, Date or Fecha, Deliverables or Entregables, tone/use."
  exit 1
fi

# Look for one required field in BRIEF.md. Exit 0 = present with content,
# 1 = missing, 2 = present but empty. The name is the whole word (or words),
# any case, in one of two styles:
#   heading  "# Client", "## Client: Acme" (any level). Content is the text
#            after ":" or any non-blank line before the next heading of the
#            same or a higher level.
#   field    "**Client:** Acme" or "**Client**: Acme". Content is the text
#            after it on the same line.
# "# Client notes", "# Clientes: Acme" and "**Clients:** Acme" do not count.
find_field() {
  awk -v names="$1" '
    function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t\r]+$/, "", s); return s }
    function known(s,   i) {
      s = trim(s)
      for (i = 1; i <= n; i++) if (s == want[i]) return 1
      return 0
    }
    BEGIN { n = split(tolower(names), want, "|"); found = 0; ok = 0; open = 0 }
    {
      line = $0
      sub(/\r$/, "", line)
      low = tolower(line)
    }
    low ~ /^#/ {
      h = low
      level = 0
      while (substr(h, 1, 1) == "#") { level++; h = substr(h, 2) }
      if (open && level <= open) open = 0
      if (open) next
      name = h; val = ""
      i = index(h, ":")
      if (i > 0) { name = substr(h, 1, i - 1); val = trim(substr(h, i + 1)) }
      if (known(name)) {
        found = 1
        if (val != "") ok = 1; else open = level
      }
      next
    }
    {
      if (open && trim(line) != "") { ok = 1; open = 0 }
      f = trim(low)
      if (substr(f, 1, 2) != "**") next
      f = substr(f, 3)
      j = index(f, "**")
      if (j == 0) next
      name = substr(f, 1, j - 1)
      rest = substr(f, j + 2)
      if (substr(name, length(name), 1) == ":") {
        name = substr(name, 1, length(name) - 1)
      } else if (substr(trim(rest), 1, 1) == ":") {
        rest = substr(trim(rest), 2)
      } else {
        next
      }
      if (known(name)) {
        found = 1
        if (trim(rest) != "") ok = 1
      }
    }
    END { if (ok) exit 0; if (found) exit 2; exit 1 }
  ' BRIEF.md
}

# Each field: English name, Spanish name, then any further accepted names.
for fields in "Client|Cliente" "Date|Fecha|Delivery date|Fecha de entrega" "Deliverables|Entregables"; do
  rest="${fields#*|}"
  en="${fields%%|*}"
  es="${rest%%|*}"
  st=0
  find_field "$fields" || st=$?
  if [[ "$st" -eq 1 ]]; then
    echo "✗ BRIEF.md is missing heading «${en}» or «${es}»"
    fail=1
  elif [[ "$st" -eq 2 ]]; then
    echo "✗ BRIEF.md section «${en}» / «${es}» is empty: write it under the heading or after the colon"
    fail=1
  elif [[ "$st" -ne 0 ]]; then
    echo "✗ Could not read BRIEF.md (awk exit $st)"
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
