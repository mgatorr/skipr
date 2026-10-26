#!/usr/bin/env bash
# fdd setup --user: turns the context meter on in ~/.claude/settings.json,
# backup first, and --remove takes back exactly what it added.
# Every case runs in a temporary HOME. fdd runs on the bash that runs this
# test, so /bin/bash checks bash 3.2.
set -u

root="$(cd "$(dirname "$0")/.." && pwd)"
fdd="$root/skills/fdd/bin/fdd"
template="$root/skills/fdd/templates/user-settings.json"
tools="$root/skills/fdd/tools.md"
fail=0
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
export TMPDIR="$work/tmp" GIT_CONFIG_NOSYSTEM=1
mkdir -p "$TMPDIR"

pass() { printf 'PASS %s\n' "$1"; }
bad() { printf 'FAIL %s\n' "$1"; fail=1; }
check() { if eval "$2"; then pass "$1"; else bad "$1"; fi; }
has() { printf '%s' "$1" | grep -qF -- "$2"; }
has_line() { printf '%s\n' "$1" | grep -qxF -- "$2"; }
last_line() { printf '%s\n' "$1" | sed '/^$/d' | tail -1; }

# The exact strings setup writes. $HOME stays literal: Claude Code expands it.
S='"$HOME/.claude/skills/fdd/bin/fdd" statusline'
H='"$HOME/.claude/skills/fdd/bin/fdd" hook --warn-only'
FULL='"$HOME/.claude/skills/fdd/bin/fdd" hook'
# The same two commands as JSON text, in the snippet to paste by hand.
JS='\"$HOME/.claude/skills/fdd/bin/fdd\" statusline'
JH='\"$HOME/.claude/skills/fdd/bin/fdd\" hook --warn-only'
FOREIGN_LINE='Warnings stay off until your status line calls fdd statusline'
SNIPPET_LINE='meter="$(printf '"'%s'"' "$in" | "$HOME/.claude/skills/fdd/bin/fdd" statusline)"'

fresh() { # a new empty HOME for one case
  HOME="$work/home-$1"
  export HOME
  rm -rf "$HOME"
  mkdir -p "$HOME"
  settings="$HOME/.claude/settings.json"
  backups="$HOME/.claude/settings-backup"
}
put() { mkdir -p "$HOME/.claude" && printf '%s' "$1" >"$settings"; }
setup() { "$BASH" "$fdd" setup "$@"; }
backup_count() { ls -A "$backups" 2>/dev/null | wc -l | tr -d ' '; }
# Files in ~/.claude other than settings.json and the backup folder.
strays() { ls -A "$HOME/.claude" 2>/dev/null | grep -vxF -e settings.json -e settings-backup; }
# Run perl code against the decoded file in $j; prints what the code returns.
jget() { perl -MJSON::PP -e 'local $/; open my $f, "<", $ARGV[0] or exit 2; our $j = JSON::PP->new->utf8->decode(<$f>); my $r = eval $ARGV[1]; print defined $r ? $r : ""' "$1" "$2"; }
deep_eq() { perl -MJSON::PP -e 'my $c = JSON::PP->new->utf8->canonical; sub r { local $/; open my $f, "<", $_[0] or exit 2; $c->decode(<$f>) } exit($c->encode(r($ARGV[0])) eq $c->encode(r($ARGV[1])) ? 0 : 1)' "$1" "$2"; }
# How many hook objects under hooks.$2 run exactly command $3.
hook_count() {
  CMD="$3" jget "$1" 'my $n = 0; for my $e (@{ $j->{hooks}{'"$2"'} || [] }) { next unless ref $e eq "HASH" && ref $e->{hooks} eq "ARRAY"; $n += grep { ref $_ eq "HASH" && ($_->{command} // "") eq $ENV{CMD} } @{ $e->{hooks} } } $n'
}
status_cmd() { jget "$1" '$j->{statusLine}{command}'; }
has_backup_of() { local b; for b in "$backups"/*; do cmp -s "$b" "$1" && return 0; done; return 1; }

# 0. The template holds both keys and stays short.
check "user-settings.json is at most 12 lines" '[ -f "$template" ] && [ "$(wc -l <"$template" | tr -d " ")" -le 12 ]'
check "user-settings.json names the statusline and the warn-only hook" '[ -f "$template" ] && [ "$(status_cmd "$template")" = "$S" ] && [ "$(hook_count "$template" UserPromptSubmit "$H")" = 1 ]'

# 1. No settings file: setup writes one with both keys, and says why.
fresh none
ec=0; out="$(setup --user --yes 2>&1)" || ec=$?
check "no file: setup exits 0 and writes the file" '[ "$ec" = 0 ] && [ -f "$settings" ]'
check "no file: the statusLine calls fdd statusline" '[ "$(status_cmd "$settings")" = "$S" ]'
check "no file: one warn-only UserPromptSubmit hook" '[ "$(hook_count "$settings" UserPromptSubmit "$H")" = 1 ]'
check "no file: the result is the template" 'deep_eq "$settings" "$template"'
check "no file: no Stop hook and no full hook at user level" '[ "$(hook_count "$settings" Stop "$FULL")" = 0 ] && [ "$(hook_count "$settings" UserPromptSubmit "$FULL")" = 0 ]'
check "no file: the plan names both keys with a why" 'has "$out" "statusLine" && has "$out" "hooks.UserPromptSubmit" && [ "$(printf "%s\n" "$out" | grep -c "why:")" -ge 2 ]'
check "no file: says new sessions only, on the last line" 'has "$out" "new sessions only" && has "$(last_line "$out")" "Applies to new sessions only"'
check "no file: 2-space canonical JSON" '[ "$(sed -n 2p "$settings")" = "  \"hooks\": {" ]'
check "no file: nothing to back up, no stray temp file" '[ "$(backup_count)" = 0 ] && [ -z "$(strays)" ]'

# 2. A second run changes nothing.
cp "$settings" "$work/first.json"
ec=0; out="$(setup --user --yes 2>&1)" || ec=$?
check "second run: exit 0 and byte-identical file" '[ "$ec" = 0 ] && cmp -s "$settings" "$work/first.json"'
check "second run: still exactly one hook entry" '[ "$(hook_count "$settings" UserPromptSubmit "$H")" = 1 ]'
check "second run: no backup for a run that writes nothing" '[ "$(backup_count)" = 0 ]'
check "second run: last line says new sessions only" 'has "$(last_line "$out")" "Applies to new sessions only"'

# 3. Unrelated keys and nested arrays stay; the backup keeps the original bytes.
fresh keep
ORIG='{"model":"opus","permissions":{"allow":["Bash(ls:*)","Read"],"deny":[]},
 "env":{"A":"1"},"n":3,"flag":true,"nested":[[1,2],[{"x":null}]],
 "hooks":{"Stop":[{"matcher":"","hooks":[{"type":"command","command":"say done"}]}],
  "UserPromptSubmit":[{"hooks":[{"type":"command","command":"echo hi"}]}]}}'
put "$ORIG"
cp "$settings" "$work/keep.orig"
ec=0; out="$(setup --user --yes 2>&1)" || ec=$?
check "keep: exit 0, both keys added" '[ "$ec" = 0 ] && [ "$(status_cmd "$settings")" = "$S" ] && [ "$(hook_count "$settings" UserPromptSubmit "$H")" = 1 ]'
CMD_S="$S" CMD_H="$H" jget "$settings" '
  delete $j->{statusLine};
  for my $e (@{ $j->{hooks}{UserPromptSubmit} }) { $e->{hooks} = [ grep { $_->{command} ne $ENV{CMD_H} } @{ $e->{hooks} } ] }
  $j->{hooks}{UserPromptSubmit} = [ grep { @{ $_->{hooks} } } @{ $j->{hooks}{UserPromptSubmit} } ];
  JSON::PP->new->utf8->canonical->encode($j)' >"$work/keep.stripped"
check "keep: everything else is deep-equal to the original" 'deep_eq "$work/keep.stripped" "$work/keep.orig"'
check "keep: the user hooks are still there" '[ "$(hook_count "$settings" UserPromptSubmit "echo hi")" = 1 ] && [ "$(hook_count "$settings" Stop "say done")" = 1 ]'
check "keep: exactly one backup" '[ "$(backup_count)" = 1 ]'
check "keep: the backup is byte-identical to the original" 'cmp -s "$backups/$(ls -A "$backups" | head -1)" "$work/keep.orig"'
check "keep: the backup is named settings.json.<suffix>" 'ls -A "$backups" | grep -qE "^settings\.json\.[A-Za-z0-9]+$"'
check "keep: no stray temp file" '[ -z "$(strays)" ]'

# 4. Invalid JSON: refuse, change nothing, write no backup, print the snippet.
fresh invalid
put '{"model": "opus",'
cp "$settings" "$work/invalid.orig"
ec=0; out="$(setup --user --yes 2>&1)" || ec=$?
check "invalid: exits 1" '[ "$ec" = 1 ]'
check "invalid: file byte-identical" 'cmp -s "$settings" "$work/invalid.orig"'
check "invalid: no backup and no temp file" '[ ! -e "$backups" ] && [ -z "$(strays)" ]'
check "invalid: prints the snippet to paste by hand" 'has "$out" "$JS" && has "$out" "$JH"'
check "invalid: last line says new sessions only" 'has "$(last_line "$out")" "Applies to new sessions only"'

# 5. A symlink is refused.
fresh link
mkdir -p "$HOME/.claude"
printf '{"model":"opus"}\n' >"$work/dotfiles-settings.json"
cp "$work/dotfiles-settings.json" "$work/link.orig"
ln -s "$work/dotfiles-settings.json" "$settings"
ec=0; out="$(setup --user --yes 2>&1)" || ec=$?
check "symlink: exits 1 and says symlink" '[ "$ec" = 1 ] && has "$out" "symlink"'
check "symlink: the link and its target are untouched" '[ -L "$settings" ] && cmp -s "$work/dotfiles-settings.json" "$work/link.orig"'
check "symlink: no backup, snippet printed" '[ ! -e "$backups" ] && has "$out" "$JH"'

# 6. A status line of your own is kept, and warnings stay off.
fresh foreign
put '{"statusLine":{"type":"command","command":"~/bin/mine.sh"}}'
cp "$settings" "$work/foreign.orig"
ec=0; out="$(setup --user --yes 2>&1)" || ec=$?
check "foreign: exit 0, status line kept, file byte-identical" '[ "$ec" = 0 ] && [ "$(status_cmd "$settings")" = "~/bin/mine.sh" ] && cmp -s "$settings" "$work/foreign.orig"'
check "foreign: no hook added" '[ "$(hook_count "$settings" UserPromptSubmit "$H")" = 0 ]'
check "foreign: prints the exact warnings-off line" 'has_line "$out" "$FOREIGN_LINE"'
check "foreign: prints the snippet that tools.md shows" 'has_line "$out" "$SNIPPET_LINE" && grep -qxF -- "$SNIPPET_LINE" "$tools"'
snippet="$(printf "%s\n" "$out" | sed -n "/^#!\/bin\/bash$/,/^printf /p")"
check "foreign: every snippet line is in tools.md" '[ "$(printf "%s\n" "$snippet" | wc -l | tr -d " ")" -ge 5 ] && printf "%s\n" "$snippet" | while IFS= read -r l; do grep -qxF -- "$l" "$tools" || exit 1; done'
check "foreign: no backup" '[ "$(backup_count)" = 0 ]'
# The pair: a status line script that calls fdd statusline gets the hook.
fresh wraps
mkdir -p "$HOME/.claude"
printf '#!/bin/bash\nin="$(cat)"\nprintf "%%s" "$in" | "$HOME/.claude/skills/fdd/bin/fdd" statusline\n' >"$HOME/.claude/statusline.sh"
put '{"statusLine":{"type":"command","command":"bash ~/.claude/statusline.sh"}}'
ec=0; out="$(setup --user --yes 2>&1)" || ec=$?
check "wrapper: a script that calls fdd statusline is kept and gets the hook" '[ "$ec" = 0 ] && [ "$(status_cmd "$settings")" = "bash ~/.claude/statusline.sh" ] && [ "$(hook_count "$settings" UserPromptSubmit "$H")" = 1 ]'
check "wrapper: no warnings-off line" '! has "$out" "$FOREIGN_LINE"'

# 7. --dry-run prints the plan, exits 0, writes nothing.
fresh dry
put '{"model":"opus"}'
cp "$settings" "$work/dry.orig"
ec=0; out="$(setup --user --dry-run </dev/null 2>&1)" || ec=$?
check "dry-run: exit 0 and prints both planned keys" '[ "$ec" = 0 ] && has "$out" "statusLine" && has "$out" "hooks.UserPromptSubmit"'
check "dry-run: file byte-identical, no backup, no temp file" 'cmp -s "$settings" "$work/dry.orig" && [ ! -e "$backups" ] && [ -z "$(strays)" ]'
check "dry-run: last line says new sessions only" 'has "$(last_line "$out")" "Applies to new sessions only"'
fresh dry-none
ec=0; out="$(setup --user --dry-run </dev/null 2>&1)" || ec=$?
check "dry-run with no file: exit 0, creates nothing" '[ "$ec" = 0 ] && has "$out" "statusLine" && [ ! -e "$HOME/.claude" ]'

# 8. Without --yes it asks y/N, after the plan and the new-sessions line.
fresh ask
put '{"model":"opus"}'
cp "$settings" "$work/ask.orig"
ec=0; out="$(printf 'n\n' | setup --user 2>&1)" || ec=$?
check "ask: the question is y/N" 'has "$out" "[y/N]"'
check "ask: the plan and the new-sessions line come before the question" 'OUT="$out" perl -e '"'"'my $o = $ENV{OUT}; my $q = index($o, "[y/N]"); exit(($q > index($o, "Applies to new sessions only; close open Claude Code sessions first.") && index($o, "Applies to new sessions only; close") >= 0 && index($o, "hooks.UserPromptSubmit") < $q) ? 0 : 1)'"'"''
check "ask: n changes nothing" '[ "$ec" = 0 ] && cmp -s "$settings" "$work/ask.orig" && [ ! -e "$backups" ]'
ec=0; out="$(printf '' | setup --user 2>&1)" || ec=$?
check "ask: no answer changes nothing" 'cmp -s "$settings" "$work/ask.orig"'
ec=0; out="$(printf 'y\n' | setup --user 2>&1)" || ec=$?
check "ask: y writes" '[ "$ec" = 0 ] && [ "$(hook_count "$settings" UserPromptSubmit "$H")" = 1 ]'
ec=0; out="$(setup --yes 2>&1)" || ec=$?
check "setup without --user is refused" '[ "$ec" != 0 ] && has "$out" "--user"'

# 9. --remove gives back the file as it was before setup.
fresh remove
put "$ORIG"
cp "$settings" "$work/remove.orig"
setup --user --yes >/dev/null 2>&1
cp "$settings" "$work/remove.after-setup"
check "remove: setup added the hook first" '[ "$(hook_count "$settings" UserPromptSubmit "$H")" = 1 ]'
ec=0; out="$(setup --user --remove --yes 2>&1)" || ec=$?
check "remove: exit 0 and deep-equal to the pre-setup file" '[ "$ec" = 0 ] && deep_eq "$settings" "$work/remove.orig"'
check "remove: backs up first (a second backup, the post-setup bytes)" '[ "$(backup_count)" = 2 ] && has_backup_of "$work/remove.after-setup"'
check "remove: last line says new sessions only" 'has "$(last_line "$out")" "Applies to new sessions only"'
ec=0; out="$(setup --user --remove --yes 2>&1)" || ec=$?
check "remove twice: nothing to remove, no new backup" '[ "$ec" = 0 ] && [ "$(backup_count)" = 2 ] && deep_eq "$settings" "$work/remove.orig"'
# fdd entries the user added by hand survive --remove.
fresh mine
USER_FDD='{"statusLine":{"type":"command","command":"~/.claude/skills/fdd/bin/fdd statusline","padding":0},
 "hooks":{"UserPromptSubmit":[{"hooks":[{"type":"command","command":"\"$HOME/.claude/skills/fdd/bin/fdd\" hook"}]}],
  "Stop":[{"hooks":[{"type":"command","command":"\"$HOME/.claude/skills/fdd/bin/fdd\" hook"}]}]}}'
put "$USER_FDD"
cp "$settings" "$work/mine.orig"
setup --user --yes >/dev/null 2>&1
check "mine: setup keeps the hand-set statusLine and adds the warn-only hook" '[ "$(status_cmd "$settings")" = "~/.claude/skills/fdd/bin/fdd statusline" ] && [ "$(hook_count "$settings" UserPromptSubmit "$H")" = 1 ]'
setup --user --remove --yes >/dev/null 2>&1
check "mine: after --remove the user fdd entries are all there" 'deep_eq "$settings" "$work/mine.orig"'
check "mine: the full hook and the Stop hook survive" '[ "$(hook_count "$settings" UserPromptSubmit "$FULL")" = 1 ] && [ "$(hook_count "$settings" Stop "$FULL")" = 1 ] && [ "$(hook_count "$settings" UserPromptSubmit "$H")" = 0 ]'
# The hook inside an entry of the user's own: only that hook goes.
fresh shared
put '{"hooks":{"UserPromptSubmit":[{"hooks":[{"type":"command","command":"echo hi"},{"type":"command","command":"\"$HOME/.claude/skills/fdd/bin/fdd\" hook --warn-only"}]}]}}'
setup --user --remove --yes >/dev/null 2>&1
check "shared: only the warn-only hook leaves the entry" '[ "$(hook_count "$settings" UserPromptSubmit "echo hi")" = 1 ] && [ "$(hook_count "$settings" UserPromptSubmit "$H")" = 0 ]'
ec=0; out="$(setup --user --remove --dry-run 2>&1)" || ec=$?
check "remove --dry-run on a clean file: nothing to remove" '[ "$ec" = 0 ] && has "$(last_line "$out")" "Applies to new sessions only"'

# 10. A change between the read and the mv aborts the write.
fresh race
put '{"model":"opus"}'
FDD_SETUP_TEST_SLEEP=3 "$BASH" "$fdd" setup --user --yes >"$work/race.out" 2>&1 &
pid=$!
i=0
while [ "$i" -lt 100 ] && [ -z "$(strays)" ]; do sleep 0.1; i=$((i + 1)); done
printf '{"model":"sonnet","edited":"by another session"}\n' >"$settings"
cp "$settings" "$work/race.theirs"
ec=0; wait "$pid" || ec=$?
out="$(cat "$work/race.out")"
check "race: the temp file appeared while merging" '[ "$i" -lt 100 ]'
check "race: exits 1 and says settings changed while merging, run again" '[ "$ec" = 1 ] && has "$out" "settings changed while merging, run again"'
check "race: the other change is kept" 'cmp -s "$settings" "$work/race.theirs"'
check "race: no temp file left" '[ -z "$(strays)" ]'
# The pair: the same pause with no change writes.
fresh calm
put '{"model":"opus"}'
ec=0; FDD_SETUP_TEST_SLEEP=1 "$BASH" "$fdd" setup --user --yes >/dev/null 2>&1 || ec=$?
check "calm: the same pause without a change writes" '[ "$ec" = 0 ] && [ "$(hook_count "$settings" UserPromptSubmit "$H")" = 1 ]'

# 11. The docs say how to undo it.
check "tools.md has a Setup at user level section" 'grep -qE "^## Setup at user level" "$tools"'
check "tools.md says to remove before deleting the skill" 'grep -qF "run fdd setup --user --remove before deleting the skill" "$tools"'
check "tools.md names the backup folder" 'grep -qF "~/.claude/settings-backup/" "$tools"'

if [ "$fail" -eq 0 ]; then
  printf 'fdd setup: PASS\n'
  exit 0
fi
printf 'fdd setup: FAIL\n'
exit 1
