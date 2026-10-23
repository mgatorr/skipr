#!/usr/bin/env bash
# Fail when tracked files break the docs limits.
set -euo pipefail

if locale -a 2>/dev/null | grep -qx 'C.utf8'; then
  export LC_ALL=C.utf8
elif locale -a 2>/dev/null | grep -qx 'C.UTF-8'; then
  export LC_ALL=C.UTF-8
else
  export LC_ALL=en_US.UTF-8
fi

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

fail=0
report() {
  printf '%s\n' "$*" >&2
  fail=1
}

# Banned terms come from DOCS_BANNED (CI secret) or, if that is unset or
# empty, from the gitignored file .docs-banned at the repo root. Format: one
# term per line; blank lines and lines starting with # are ignored. A term may
# be several words. A line starting with = is matched in exact case;
# every other term is matched case-insensitively. Matching is on whole words.
banned_list="${DOCS_BANNED:-}"
banned_source="DOCS_BANNED"
if [[ -z "$banned_list" && -f .docs-banned ]]; then
  banned_list="$(cat .docs-banned)"
  banned_source=".docs-banned"
fi
if [[ -z "${banned_list//[[:space:]]/}" ]]; then
  printf 'warning: no banned-term list (set DOCS_BANNED or create .docs-banned); skipping the term scan\n' >&2
  banned_list=""
fi
export DOCS_BANNED_LIST="$banned_list"

# Prints file:line:text for each hit and exits 1 if there is one.
# Files that are not valid UTF-8 text (binary) are skipped.
banned_scanner='
use strict; use warnings;
use Encode qw(decode FB_CROAK);
use Unicode::Normalize qw(NFC);
my ($file) = @ARGV;
my (%ci, %cs); my $max = 1;
for my $t (split /\r?\n/, decode("UTF-8", $ENV{DOCS_BANNED_LIST} // "")) {
  $t =~ s/^\s+|\s+$//g;
  next if $t eq "" || $t =~ /^#/;
  my $exact = $t =~ s/^=//;
  my @w = NFC($t) =~ /(\w+)/g;
  next unless @w;
  $max = @w if @w > $max;
  if ($exact) { $cs{ join " ", @w } = 1 } else { $ci{ lc join " ", @w } = 1 }
}
exit 0 unless %ci || %cs;
open my $fh, "<:raw", $file or exit 0;
my $raw = do { local $/; <$fh> };
close $fh;
exit 0 if $raw =~ /\x00/;
my $text = eval { decode("UTF-8", $raw, FB_CROAK) };
exit 0 unless defined $text;
my ($n, $hit) = (0, 0);
binmode STDERR, ":encoding(UTF-8)";
for my $line (split /\n/, $text, -1) {
  $n++;
  my @w = NFC($line) =~ /(\w+)/g;
  my $found = 0;
  WORD: for my $i (0 .. $#w) {
    for my $k (1 .. $max) {
      last if $i + $k > @w;
      my $g = join " ", @w[$i .. $i + $k - 1];
      if ($cs{$g} || $ci{ lc $g }) { $found = 1; last WORD; }
    }
  }
  if ($found) { $hit = 1; print STDERR "$file:$n:$line\n"; }
}
exit $hit;
'

scan_banned() {
  local f="$1"
  [[ -n "$DOCS_BANNED_LIST" ]] || return 0
  if ! perl -e "$banned_scanner" -- "$f"; then
    fail=1
  fi
}

scan_links() {
  local f="$1" dir lineno match path target
  dir=$(dirname -- "$f")
  while IFS=: read -r lineno match; do
    [[ -n "${match:-}" ]] || continue
    path=${match#](}
    path=${path%%#*}
    path=${path%%\?*}
    path=${path#<}
    path=${path%>}
    if [[ -z "$path" ]]; then
      report "$f:$lineno: empty relative link"
      continue
    fi
    target="$dir/$path"
    if [[ ! -e "$target" ]]; then
      report "$f:$lineno: missing $path"
    fi
  done < <(grep -n -o -E '\]\(\.\.?/[^)[:space:]]+' -- "$f" || true)
}

check_cap() {
  local f="$1" cap="$2" lines
  [[ -f "$f" ]] || return 0
  lines=$(wc -l < "$f")
  lines=${lines//[[:space:]]/}
  if (( lines > cap )); then
    report "$f has $lines lines (cap $cap)"
  fi
}

scan_tree_file() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  scan_banned "$f"
  if [[ "$f" == *.md ]]; then
    scan_links "$f"
  fi
}

while IFS= read -r -d '' f; do
  scan_tree_file "$f"
done < <(git ls-files -z --)

for extra in "$@"; do
  if [[ ! -f "$extra" ]]; then
    report "not a file: $extra"
    continue
  fi
  scan_tree_file "$extra"
done

check_cap "CLAUDE.md" 60
check_cap "skills/fdd/SKILL.md" 100
check_cap "skills/fdd/templates/note.md" 60
check_cap ".skipr/rules.md" 40

if (( fail == 0 )); then
  printf 'docs check ok\n'
  exit 0
fi
exit 1
