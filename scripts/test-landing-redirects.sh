#!/usr/bin/env bash
# Every docs page skipr.dev ever linked must land on a file that exists: the
# current one on main, its English page for an old Spanish one, or the
# era-spec-kit tag for a page the P0 removed.
set -u

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
tag="era-spec-kit"
if ! git rev-parse -q --verify "refs/tags/$tag" >/dev/null; then
  git fetch -q origin "refs/tags/$tag:refs/tags/$tag" 2>/dev/null ||
    { printf 'FAIL tag %s not found\n' "$tag"; printf 'landing redirects: FAIL\n'; exit 1; }
fi

{ git ls-tree -r --name-only "$tag" docs; git ls-files docs; } | sort -u |
  TAG="$tag" perl -MJSON::PP -e '
    use strict; use warnings;
    local $/; my ($json, $paths) = do { open my $f, "<", "landing/vercel.json" or die; (scalar <$f>, scalar <STDIN>) };
    my $rules = decode_json($json)->{redirects};
    my $fail = 0;
    sub exists_at { my ($ref, $p) = @_; system("git", "cat-file", "-e", "$ref:$p") == 0 }
    for my $p (split /\n/, $paths) {
      my $url = "/$p";
      my $dest;
      for my $r (@$rules) {
        my $src = $r->{source};
        my $re = quotemeta($src);
        $re =~ s/\\:path\\\*/(.*)/;
        if ($url =~ /^$re$/) { my $rest = $1 // ""; ($dest = $r->{destination}) =~ s/:path\*/$rest/; last }
      }
      my ($ref, $file) = defined $dest && $dest =~ m{^https://github\.com/mgatorr/skipr/blob/([^/]+)/(.+)$} ? ($1, $2) : ();
      my $ok = defined $ref && ($ref eq "main" ? -e $file : $ref eq $ENV{TAG} ? exists_at($ref, $file) : 0);
      printf "%s %s -> %s\n", ($ok ? "PASS" : "FAIL"), $url, $dest // "(no rule)";
      $fail = 1 unless $ok;
    }
    printf "landing redirects: %s\n", $fail ? "FAIL" : "PASS";
    exit $fail;'
