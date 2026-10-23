#!/usr/bin/env bash
# Fail when tracked files break the docs limits.
set -euo pipefail
# xtrace would print the term list and any matching line. Keep it off.
set +x

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
  if [[ "${GITHUB_ACTIONS:-}" == "true" || "${CI:-}" == "true" ]]; then
    printf 'DOCS_BANNED secret not set\n' >&2
    exit 1
  fi
  printf 'warning: no banned-term list (set DOCS_BANNED or create .docs-banned); skipping the term scan\n' >&2
  banned_list=""
fi
export DOCS_BANNED_LIST="$banned_list"

# A content hit prints file:line, or [path#<sha>] when the path also matches.
# A path-only hit prints [path#<sha>] and nothing else. Never prints the term.
# Files that are not valid UTF-8 text (binary) are skipped.
banned_scanner='
use strict; use warnings;
use Encode qw(decode FB_CROAK);
use Unicode::Normalize qw(NFC);
use Digest::SHA qw(sha256_hex);
my ($file) = @ARGV;
my (%ci, %cs); my $max = 1;
sub phrase_hit {
  my ($text) = @_;
  my @w = NFC($text) =~ /(\w+)/g;
  for my $i (0 .. $#w) {
    for my $k (1 .. $max) {
      last if $i + $k > @w;
      my $g = join " ", @w[$i .. $i + $k - 1];
      return 1 if $cs{$g} || $ci{ lc $g };
    }
  }
  return 0;
}
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
my $path_hit = phrase_hit($file);
my $label = $file;
if ($path_hit) {
  $label = "[path#" . substr(sha256_hex($file), 0, 12) . "]";
}
sub path_only {
  print STDERR "$label\n" if $path_hit;
  exit($path_hit ? 1 : 0);
}
open my $fh, "<:raw", $file or path_only();
my $raw = do { local $/; <$fh> };
close $fh;
path_only() if $raw =~ /\x00/;
my $text = eval { decode("UTF-8", $raw, FB_CROAK) };
path_only() unless defined $text;
my ($n, $hit) = (0, 0);
binmode STDERR, ":encoding(UTF-8)";
for my $line (split /\n/, $text, -1) {
  $n++;
  if (phrase_hit($line)) { $hit = 1; print STDERR "$label:$n: banned term found\n"; }
}
if ($path_hit && !$hit) { print STDERR "$label\n"; $hit = 1; }
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

note="skills/fdd/templates/note.md"
if [[ -f "$note" ]]; then
  for heading in "Goal" "Why" "Questions closed" "Out of scope" "Slices" "Checks" "Evidence" "Next"; do
    if ! grep -qE "^#{1,6} ${heading}$" "$note"; then
      report "$note: missing heading ${heading}"
    fi
  done
fi

if [[ -f .skipr/rules.md && -f CLAUDE.md ]]; then
  if ! grep -qF '@.skipr/rules.md' CLAUDE.md; then
    report "CLAUDE.md: missing @.skipr/rules.md"
  fi
fi

rules=".skipr/rules.md"
prov_re='^.+ \([^)]+, [0-9]{4}-[0-9]{2}-[0-9]{2}[^)]*\)$'
if [[ -f "$rules" ]]; then
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" == "- "* ]] || continue
    if ! [[ "$line" =~ $prov_re ]]; then
      report "$rules: rule line missing provenance: $line"
    fi
  done < "$rules"
fi

if (( fail == 0 )); then
  printf 'docs check ok\n'
  exit 0
fi
exit 1
