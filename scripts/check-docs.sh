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

# Print a path or other string. If it contains a banned term (case-insensitive
# substring, separators ignored), print only [path#<12 hex sha256>].
label_for() {
  local text="$1"
  if [[ -z "${DOCS_BANNED_LIST:-}" ]]; then
    printf '%s' "$text"
    return 0
  fi
  perl -e '
use strict; use warnings;
use Encode qw(decode);
use Unicode::Normalize qw(NFC);
use Digest::SHA qw(sha256_hex);
my ($text) = @ARGV;
sub squash {
  my ($s) = @_;
  $s = lc NFC($s);
  $s =~ s/[^a-z0-9_]+//g;
  return $s;
}
my @needles;
for my $t (split /\r?\n/, decode("UTF-8", $ENV{DOCS_BANNED_LIST} // "")) {
  $t =~ s/^\s+|\s+$//g;
  next if $t eq "" || $t =~ /^#/;
  $t =~ s/^=//;
  my $n = squash($t);
  push @needles, $n if $n ne "";
}
my $hay = squash($text // "");
my $hit = 0;
if ($hay ne "") {
  for my $n (@needles) {
    if (index($hay, $n) >= 0) { $hit = 1; last; }
  }
}
if ($hit) {
  print "[path#" . substr(sha256_hex($text), 0, 12) . "]";
} else {
  print $text;
}
' -- "$text"
}

report() {
  printf '%s\n' "$(label_for "$*")" >&2
  fail=1
}

# Banned terms come from DOCS_BANNED (CI secret) or, outside CI, if that is
# unset or empty, from the gitignored file .docs-banned at the repo root. In CI
# .docs-banned is never read, so a committed decoy list cannot stand in. Format: one
# term per line; blank lines and lines starting with # are ignored. A term may
# be several words. A line starting with = is matched in exact case;
# every other term is matched case-insensitively. Content matching is whole
# words. Path and link-target matching is a case-insensitive substring.
in_ci=0
if [[ "${GITHUB_ACTIONS:-}" == "true" || "${CI:-}" == "true" ]]; then
  in_ci=1
fi
banned_list="${DOCS_BANNED:-}"
if [[ "$in_ci" -eq 0 && -z "$banned_list" && -f .docs-banned ]]; then
  banned_list="$(cat .docs-banned)"
fi
if [[ -z "${banned_list//[[:space:]]/}" ]]; then
  if [[ "$in_ci" -eq 1 ]]; then
    printf 'DOCS_BANNED secret not set\n' >&2
    exit 1
  fi
  printf 'warning: no banned-term list (set DOCS_BANNED or create .docs-banned); skipping the term scan\n' >&2
  banned_list=""
fi
export DOCS_BANNED_LIST="$banned_list"

# A content hit prints file:line, or [path#<sha>] when the path contains a term.
# Path matching is a case-insensitive substring with separators ignored.
# Content matching stays whole-word. A path-only hit prints [path#<sha>] only.
# Files with a NUL byte (binary) are skipped. Text that is not valid UTF-8 is
# read as Latin-1. Words split on anything but letters and digits, so _ is a
# separator too. Never prints the term.
banned_scanner='
use strict; use warnings;
use Encode qw(decode FB_CROAK);
use Unicode::Normalize qw(NFC);
use Digest::SHA qw(sha256_hex);
my ($file) = @ARGV;
my (%ci, %cs, @path_needles); my $max = 1;
sub squash {
  my ($s) = @_;
  $s = lc NFC($s);
  $s =~ s/[^a-z0-9_]+//g;
  return $s;
}
sub path_has_term {
  my ($text) = @_;
  my $hay = squash($text);
  return 0 if $hay eq "";
  for my $n (@path_needles) {
    return 1 if index($hay, $n) >= 0;
  }
  return 0;
}
sub phrase_hit {
  my ($text) = @_;
  my @w = NFC($text) =~ /([^\W_]+)/g;
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
  my $needle = squash($t);
  push @path_needles, $needle if $needle ne "";
  my @w = NFC($t) =~ /([^\W_]+)/g;
  next unless @w;
  $max = @w if @w > $max;
  if ($exact) { $cs{ join " ", @w } = 1 } else { $ci{ lc join " ", @w } = 1 }
}
exit 0 unless %ci || %cs;
my $path_hit = path_has_term($file);
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
$text = decode("ISO-8859-1", $raw) unless defined $text;
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
  local f="$1" dir lineno match path target flabel tlabel
  dir=$(dirname -- "$f")
  flabel="$(label_for "$f")"
  while IFS=: read -r lineno match; do
    [[ -n "${match:-}" ]] || continue
    path=${match#](}
    path=${path%%#*}
    path=${path%%\?*}
    path=${path#<}
    path=${path%>}
    if [[ -z "$path" ]]; then
      report "$flabel:$lineno: empty relative link"
      continue
    fi
    target="$dir/$path"
    if [[ ! -e "$target" ]]; then
      tlabel="$(label_for "$path")"
      report "$flabel:$lineno: missing $tlabel"
    fi
  done < <(grep -n -o -E '\]\(\.\.?/[^)[:space:]]+' -- "$f" 2>/dev/null || true)
}

check_cap() {
  local f="$1" cap="$2" lines
  [[ -f "$f" ]] || return 0
  lines=$(wc -l < "$f")
  lines=${lines//[[:space:]]/}
  if (( lines > cap )); then
    report "$(label_for "$f") has $lines lines (cap $cap)"
  fi
}

# A symlink's target is text git tracks. Check it like a path; never print it.
scan_symlink() {
  local f="$1" target tlabel
  target="$(readlink -- "$f")" || target=""
  tlabel="$(label_for "$target")"
  if [[ "$tlabel" != "$target" ]]; then
    report "$(label_for "$f"): symlink target $tlabel"
  elif [[ ! -e "$f" && "$(label_for "$f")" != "$f" ]]; then
    # Dangling, so the content scan never sees the path. Check it here.
    report "$f"
  fi
}

scan_tree_file() {
  local f="$1"
  if [[ -L "$f" ]]; then
    scan_symlink "$f"
  fi
  [[ -f "$f" ]] || return 0
  if [[ ! -r "$f" ]]; then
    report "$(label_for "$f"): unreadable"
    return 0
  fi
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
    report "not a file: $(label_for "$extra")"
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
  prov_n=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    prov_n=$((prov_n + 1))
    [[ "$line" == "- "* ]] || continue
    if ! [[ "$line" =~ $prov_re ]]; then
      report "$rules:$prov_n: rule line missing provenance"
    fi
  done < "$rules"
fi

if (( fail == 0 )); then
  printf 'docs check ok\n'
  exit 0
fi
exit 1
