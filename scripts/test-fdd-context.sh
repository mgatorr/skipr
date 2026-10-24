#!/usr/bin/env bash
# fdd statusline + hook: the context meter and its one-time warnings at 50% and 75%.
set -u

root="$(cd "$(dirname "$0")/.." && pwd)"
fdd="$root/skills/fdd/bin/fdd"
fail=0
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
export TMPDIR="$work/tmp" HOME="$work/home"
mkdir -p "$TMPDIR" "$HOME"

pass() { printf 'PASS %s\n' "$1"; }
bad() { printf 'FAIL %s\n' "$1"; fail=1; }
check() { if eval "$2"; then pass "$1"; else bad "$1"; fi; }
plain() { perl -pe 's/\e\[[0-9;]*m//g'; }

status() { # session percent
  printf '{"session_id":"%s","cwd":"%s","context_window":{"context_window_size":200000,"used_percentage":%s}}' "$1" "$work" "$2" |
    "$fdd" statusline | plain
}
prompt() { # session
  printf '{"hook_event_name":"UserPromptSubmit","session_id":"%s","cwd":"%s","prompt":"go"}' "$1" "$work" | "$fdd" hook
}
valid_json() { printf '%s' "$1" | perl -MJSON::PP -e 'local $/; decode_json(<STDIN>)' 2>/dev/null; }

# 1. The meter.
out="$(status s1 30)"
check "meter shows the figure" '[ "$out" = "context 30%" ]'
out="$(status s1 50)"
check "at 50% it suggests /compact" 'printf "%s" "$out" | grep -q "context 50%" && printf "%s" "$out" | grep -q "/compact"'
out="$(status s1 81)"
check "at 75% it says new session" 'printf "%s" "$out" | grep -q "context 81%" && printf "%s" "$out" | grep -qi "new session"'
raw="$(printf '{"session_id":"s1","context_window":{"used_percentage":81}}' | "$fdd" statusline)"
check "the 75% meter is red" 'printf "%s" "$raw" | grep -q "$(printf "\033\\[31m")"'

# 2. No figure yet (before the first response, right after /compact), or bad input.
out="$(printf '{"session_id":"s2","context_window":{"used_percentage":null,"current_usage":null}}' | "$fdd" statusline | plain)"; ec=$?
check "no figure prints no percentage and exits 0" '[ "$ec" = 0 ] && ! printf "%s" "$out" | grep -q "%"'
ec=0; printf 'nope' | "$fdd" statusline >/dev/null 2>&1 || ec=$?
check "bad input exits 0" '[ "$ec" = 0 ]'

out="$(printf '{"session_id":"s2","context_window":{"used_percentage":"abc"}}' | "$fdd" statusline | plain)"
check "a non-numeric figure is ignored" '! printf "%s" "$out" | grep -q "%"'
out="$(printf '{"session_id":"s2","context_window":{"used_percentage":[1]}}' | "$fdd" statusline | plain)"
check "a list is ignored" '! printf "%s" "$out" | grep -q "%"'

# 3. Without used_percentage, it is computed from current_usage.
out="$(printf '{"session_id":"s3","context_window":{"context_window_size":200000,"current_usage":{"input_tokens":1000,"cache_creation_input_tokens":9000,"cache_read_input_tokens":90000,"output_tokens":5000}}}' | "$fdd" statusline | plain)"
check "computes the figure from current_usage" 'printf "%s" "$out" | grep -q "context 50%"'

# 4. The hook warns once per threshold, as JSON for Claude Code.
out="$(prompt fresh)"
check "no meter reading, no warning" '[ -z "$out" ]'
status w 55 >/dev/null
out="$(prompt w)"
check "warns at 50%" 'printf "%s" "$out" | grep -q "55%"'
check "the warning is valid JSON" 'valid_json "$out"'
check "the warning reaches the human and the model" 'printf "%s" "$out" | grep -q systemMessage && printf "%s" "$out" | grep -q additionalContext'
status w 60 >/dev/null
out="$(prompt w)"
check "does not repeat the 50% warning" '[ -z "$out" ]'
status w 78 >/dev/null
out="$(prompt w)"
check "warns at 75% with new session" 'printf "%s" "$out" | grep -q "78%" && printf "%s" "$out" | grep -qi "new session"'
out="$(prompt w)"
check "does not repeat the 75% warning" '[ -z "$out" ]'

# 5. After a compaction the figure drops; the warnings are armed again.
status w 20 >/dev/null
out="$(prompt w)"
check "below 50% says nothing" '[ -z "$out" ]'
status w 52 >/dev/null
out="$(prompt w)"
check "warns again after a compaction" 'printf "%s" "$out" | grep -q "52%"'

# 6. Sessions do not share warnings; a session id cannot escape TMPDIR.
status other 55 >/dev/null
out="$(prompt other)"
check "another session gets its own warning" 'printf "%s" "$out" | grep -q "55%"'
status '../../evil' 55 >/dev/null
check "a session id cannot write outside TMPDIR" '[ -z "$(find "$work" -path "$TMPDIR" -prune -o -name "*fdd-context*" -print)" ]'

if [ "$fail" -eq 0 ]; then
  printf 'fdd context: PASS\n'
  exit 0
fi
printf 'fdd context: FAIL\n'
exit 1
