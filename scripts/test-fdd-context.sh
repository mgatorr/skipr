#!/usr/bin/env bash
# fdd statusline + hook: the context meter in tokens and its one-time warnings.
# fdd runs on the bash that runs this test, so /bin/bash checks bash 3.2.
set -u

root="$(cd "$(dirname "$0")/.." && pwd)"
fdd="$root/skills/fdd/bin/fdd"
skill="$root/skills/fdd/SKILL.md"
tools="$root/skills/fdd/tools.md"
fail=0
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
export TMPDIR="$work/tmp" HOME="$work/home" GIT_CONFIG_NOSYSTEM=1
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com
mkdir -p "$TMPDIR" "$HOME" "$work/plain"

pass() { printf 'PASS %s\n' "$1"; }
bad() { printf 'FAIL %s\n' "$1"; fail=1; }
check() { if eval "$2"; then pass "$1"; else bad "$1"; fi; }
plain() { perl -pe 's/\e\[[0-9;]*m//g'; }
has() { printf '%s' "$1" | grep -qF -- "$2"; }
run() { "$BASH" "$fdd" "$@"; }

YELLOW="$(printf '\033[33m')"
RED="$(printf '\033[31m')"
DIM="$(printf '\033[2m')"

# The status line JSON of Claude Code 2.1.310: context_window has
# total_input_tokens (input + cache_creation + cache_read of current_usage),
# total_output_tokens, context_window_size, current_usage, used_percentage and
# remaining_percentage.
fixture() { # session tokens size
  local sid="$1" t="$2" size="$3" read pct
  read=$((t - 12000))
  pct=$((100 * t / size))
  printf '{"session_id":"%s","cwd":"%s","transcript_path":"%s/none.jsonl","context_window":{"total_input_tokens":%s,"total_output_tokens":4000,"context_window_size":%s,"current_usage":{"input_tokens":2000,"output_tokens":4000,"cache_creation_input_tokens":10000,"cache_read_input_tokens":%s},"used_percentage":%s,"remaining_percentage":%s}}' \
    "$sid" "$work/plain" "$work" "$t" "$size" "$read" "$pct" "$((100 - pct))"
}
meter_raw() { fixture "$@" | run statusline; }
meter() { meter_raw "$@" | plain; }
prompt() { # session [cwd] [flag]
  printf '{"hook_event_name":"UserPromptSubmit","session_id":"%s","cwd":"%s","prompt":"go"}' "$1" "${2:-$work/plain}" |
    run hook ${3:+"$3"}
}
valid_json() { printf '%s' "$1" | perl -MJSON::PP -e 'local $/; decode_json(<STDIN>)' 2>/dev/null; }

# 1. The meter shows tokens on a 1M window.
out="$(meter s1 182000 1000000)"
check "182k on a 1M window, not a percentage" '[ "$out" = "context 182k · finish this task" ]'
raw="$(meter_raw s1 182000 1000000)"
check "182k on a 1M window is yellow" 'has "$raw" "$YELLOW"'
out="$(meter s1 262000 1000000)"; raw="$(meter_raw s1 262000 1000000)"
check "262k on a 1M window is red and says new session" '[ "$out" = "context 262k · new session" ] && has "$raw" "$RED"'
out="$(meter s1 82000 1000000)"; raw="$(meter_raw s1 82000 1000000)"
check "82k is dim with no advice" '[ "$out" = "context 82k" ] && has "$raw" "$DIM"'
out="$(meter s1 150400 1000000)"; raw="$(meter_raw s1 150400 1000000)"
check "150k is never shown dim" 'has "$out" "context 150k" && has "$raw" "$YELLOW" && ! has "$raw" "$DIM"'
out="$(meter s1 149999 1000000)"; raw="$(meter_raw s1 149999 1000000)"
check "149k is dim" '[ "$out" = "context 149k" ] && has "$raw" "$DIM"'

# 2. A 200k window keeps half and three quarters.
out="$(printf '{"session_id":"s2","context_window":{"context_window_size":200000,"used_percentage":55}}' | run statusline | plain)"
raw="$(printf '{"session_id":"s2","context_window":{"context_window_size":200000,"used_percentage":55}}' | run statusline)"
check "200k window at 55% is yellow 110k" 'has "$out" "context 110k" && has "$raw" "$YELLOW"'
raw="$(printf '{"session_id":"s2","context_window":{"context_window_size":200000,"used_percentage":81}}' | run statusline)"
check "200k window at 81% is red 162k" 'has "$(printf "%s" "$raw" | plain)" "context 162k · new session" && has "$raw" "$RED"'
out="$(printf '{"session_id":"s2","context_window":{"context_window_size":200000,"used_percentage":45}}' | run statusline | plain)"
check "200k window at 45% is dim 90k" '[ "$out" = "context 90k" ]'

# 3. Without total_input_tokens: current_usage; without a size: the constants.
raw="$(printf '{"session_id":"s3","context_window":{"context_window_size":200000,"current_usage":{"input_tokens":1000,"cache_creation_input_tokens":9000,"cache_read_input_tokens":90000,"output_tokens":5000}}}' | run statusline)"
check "current_usage sums to 100k, yellow on 200k" 'has "$(printf "%s" "$raw" | plain)" "context 100k" && has "$raw" "$YELLOW"'
raw="$(printf '{"session_id":"s3","context_window":{"total_input_tokens":160000}}' | run statusline)"
check "unknown window at 160k uses the constants (yellow)" 'has "$(printf "%s" "$raw" | plain)" "context 160k" && has "$raw" "$YELLOW"'
raw="$(printf '{"session_id":"s3","context_window":{"total_input_tokens":140000}}' | run statusline)"
check "unknown window at 140k is dim" '[ "$(printf "%s" "$raw" | plain)" = "context 140k" ]'

# 4. No size and no usage: a percentage, marked with a dim ?.
raw="$(printf '{"session_id":"s4","context_window":{"used_percentage":30}}' | run statusline)"
out="$(printf '%s' "$raw" | plain)"
check "percentage fallback shows 30% and ?" 'has "$out" "context 30%" && has "$out" "?" && ! has "$out" "k"'
raw="$(printf '{"session_id":"s4","context_window":{"used_percentage":81}}' | run statusline)"
check "percentage fallback keeps the red at 81%" 'has "$raw" "$RED" && has "$(printf "%s" "$raw" | plain)" "81%"'

# 5. No figure yet, or bad input: nothing, exit 0.
out="$(printf '{"session_id":"s5","context_window":{"total_input_tokens":0,"used_percentage":null,"current_usage":null}}' | run statusline | plain)"; ec=$?
check "no figure prints nothing and exits 0" '[ "$ec" = 0 ] && [ -z "$out" ]'
ec=0; printf 'nope' | run statusline >/dev/null 2>&1 || ec=$?
check "bad input exits 0" '[ "$ec" = 0 ]'
out="$(printf '{"session_id":"s5","context_window":{"used_percentage":"abc","total_input_tokens":"x"}}' | run statusline | plain)"
check "non-numeric figures are ignored" '[ -z "$out" ]'
out="$(printf '{"session_id":"s5","context_window":{"used_percentage":[1],"total_input_tokens":[2]}}' | run statusline | plain)"
check "lists are ignored" '[ -z "$out" ]'

# 6. The hook warns once per level, as JSON for Claude Code.
out="$(prompt fresh)"
check "no meter reading, no warning" '[ -z "$out" ]'
meter h 160000 1000000 >/dev/null
out="$(prompt h)"
check "warns at 160k on 1M" 'has "$out" "160k" && has "$out" "Every message re-sends"'
check "the warning is valid JSON" 'valid_json "$out"'
check "the warning reaches the human and the model" 'has "$out" systemMessage && has "$out" additionalContext'
check "the warning never blocks the prompt" '! has "$out" "block"'
meter h 170000 1000000 >/dev/null
out="$(prompt h)"
check "does not repeat the level 1 warning" '[ -z "$out" ]'
meter h 260000 1000000 >/dev/null
out="$(prompt h)"
check "warns again at 260k with /clear" 'has "$out" "260k" && has "$out" "/clear" && valid_json "$out"'
check "level 2 tells the model the Next line and a 5-line summary" 'has "$out" "Next" && has "$out" "5 lines"'
out="$(prompt h)"
check "does not repeat the level 2 warning" '[ -z "$out" ]'

# 7. Straight to 260k, then down to 200k: no stale level 1 warning.
meter j 260000 1000000 >/dev/null
out="$(prompt j)"
check "a jump to 260k warns at level 2" 'has "$out" "260k"'
meter j 200000 1000000 >/dev/null
out="$(prompt j)"
check "then 200k gives no level 1 warning" '[ -z "$out" ]'

# 8. A drop below the first threshold (a /clear or a compaction) re-arms both.
meter h 50000 1000000 >/dev/null
out="$(prompt h)"
check "50k says nothing" '[ -z "$out" ]'
meter h 160000 1000000 >/dev/null
out="$(prompt h)"
check "warns again after a drop" 'has "$out" "160k"'

# 9. Concurrent hooks (user level and project level) print one warning per level.
burst() { # session out-prefix
  local i
  for i in 1 2 3 4 5 6 7 8 9 10; do
    prompt "$1" >"$2.a$i" 2>&1 &
    prompt "$1" "$work/plain" --warn-only >"$2.b$i" 2>&1 &
  done
  wait
}
count() { grep -l systemMessage "$1".* 2>/dev/null | wc -l | tr -d ' '; }
mkdir -p "$work/burst"
meter c 160000 1000000 >/dev/null
burst c "$work/burst/one"
check "20 concurrent hooks at 160k: exactly one warning" '[ "$(count "$work/burst/one")" = 1 ] && grep -q 160k "$work"/burst/one.*'
meter c 260000 1000000 >/dev/null
burst c "$work/burst/two"
check "20 concurrent hooks at 260k: exactly one warning" '[ "$(count "$work/burst/two")" = 1 ] && grep -q 260k "$work"/burst/two.*'

# 10. --warn-only never snapshots, even in a git repository.
repo="$work/repo"
mkdir -p "$repo" && git -C "$repo" init -q -b main
printf 'photo\n' >"$repo/untracked.txt"
meter r 30000 1000000 >/dev/null
prompt r "$repo" --warn-only >/dev/null
check "--warn-only makes no fdd ref" '[ -z "$(git -C "$repo" for-each-ref refs/worktree/fdd)" ]'
prompt r "$repo" >/dev/null
check "a plain hook in the same repo does make one" '[ -n "$(git -C "$repo" for-each-ref refs/worktree/fdd)" ]'
meter r2 160000 1000000 >/dev/null
out="$(prompt r2 "$repo" --warn-only)"
check "--warn-only still warns" 'has "$out" "160k" && valid_json "$out"'

# 11. A file in the old one-number format is no reading; the new one is.
printf '80\n' >"$TMPDIR/fdd-context-old"
ec=0; out="$(prompt old 2>&1)" || ec=$?
check "an old one-number file gives no warning and no error" '[ "$ec" = 0 ] && [ -z "$out" ]'
printf '160000 1000000\n' >"$TMPDIR/fdd-context-new"
out="$(prompt new)"
check "a tokens-and-size file warns" 'has "$out" "160k"'
meter d 160000 1000000 >/dev/null
printf '{"session_id":"d","context_window":{"used_percentage":30}}' | run statusline >/dev/null
out="$(prompt d)"
check "a percentage-only reading leaves no stale tokens behind" '[ -z "$out" ]'
ec=0; out="$(printf 'nope' | run hook 2>&1)" || ec=$?
check "the hook exits 0 on bad input" '[ "$ec" = 0 ] && [ -z "$out" ]'

# 12. Sessions do not share warnings; a session id cannot escape TMPDIR.
meter other 160000 1000000 >/dev/null
out="$(prompt other)"
check "another session gets its own warning" 'has "$out" "160k"'
fixture '../../evil' 160000 1000000 | run statusline >/dev/null
check "a session id cannot write outside TMPDIR" '[ -z "$(find "$work" -path "$TMPDIR" -prune -o -name "*fdd-context*" -print)" ]'

# 13. The docs quote the thresholds the script uses, never the old percentages.
warn="$(sed -n 's/^FDD_WARN_TOKENS=\([0-9][0-9]*\)$/\1/p' "$fdd")"
stop="$(sed -n 's/^FDD_STOP_TOKENS=\([0-9][0-9]*\)$/\1/p' "$fdd")"
check "bin/fdd names FDD_WARN_TOKENS and FDD_STOP_TOKENS" '[ -n "$warn" ] && [ -n "$stop" ]'
for doc in "$skill" "$tools"; do
  name="$(basename "$doc")"
  check "$name quotes both thresholds in k" '[ -n "$warn" ] && [ -n "$stop" ] && grep -qF "$((warn / 1000))k" "$doc" && grep -qF "$((stop / 1000))k" "$doc"'
  check "$name has no literal 50% or 75%" '! grep -qF "50%" "$doc" && ! grep -qF "75%" "$doc"'
done

if [ "$fail" -eq 0 ]; then
  printf 'fdd context: PASS\n'
  exit 0
fi
printf 'fdd context: FAIL\n'
exit 1
