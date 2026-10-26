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

# 11. setup --help exits 0 and writes nothing: the installer probes with it.
fresh help
ec=0; out="$(setup --help 2>&1)" || ec=$?
check "help: setup --help exits 0 and prints the usage" '[ "$ec" = 0 ] && has "$out" "fdd setup --user [--dry-run] [--yes] [--remove]"'
check "help: setup --help writes nothing" '[ ! -e "$HOME/.claude" ]'
ec=0; setup --nonsense >/dev/null 2>&1 || ec=$?
check "help: an unknown option still exits non-zero" '[ "$ec" != 0 ]'

# 12. The docs say how to undo it.
check "tools.md has a Setup at user level section" 'grep -qE "^## Setup at user level" "$tools"'
check "tools.md says to remove before deleting the skill" 'grep -qF "run fdd setup --user --remove before deleting the skill" "$tools"'
check "tools.md names the backup folder" 'grep -qF "~/.claude/settings-backup/" "$tools"'

# 13. --remove drops an entry whose hooks list it empties, whatever else it holds.
fresh matcher
put '{"hooks":{"UserPromptSubmit":[{"matcher":"","hooks":[{"type":"command","command":"\"$HOME/.claude/skills/fdd/bin/fdd\" hook --warn-only"}]}]}}'
ec=0; setup --user --remove --yes >/dev/null 2>&1 || ec=$?
check "matcher: no entry is left without a hooks list" '[ "$ec" = 0 ] && [ "$(jget "$settings" "my \$n = 0; for my \$e (@{ \$j->{hooks}{UserPromptSubmit} || [] }) { \$n++ unless ref \$e->{hooks} eq q(ARRAY) } \$n")" = 0 ]'
check "matcher: the emptied lists go too" '[ "$(jget "$settings" "exists \$j->{hooks} ? 1 : 0")" = 0 ]'
# The pair: an entry that still holds a hook of yours keeps its matcher.
fresh matcher-kept
put '{"hooks":{"UserPromptSubmit":[{"matcher":"x","hooks":[{"type":"command","command":"echo hi"},{"type":"command","command":"\"$HOME/.claude/skills/fdd/bin/fdd\" hook --warn-only"}]}]}}'
setup --user --remove --yes >/dev/null 2>&1
check "matcher-kept: the matcher and your hook stay" '[ "$(jget "$settings" "\$j->{hooks}{UserPromptSubmit}[0]{matcher}")" = x ] && [ "$(hook_count "$settings" UserPromptSubmit "echo hi")" = 1 ] && [ "$(hook_count "$settings" UserPromptSubmit "$H")" = 0 ]'

# 14. --remove names a status line that still runs the meter but is not setup's.
fresh edited
put '{}'
setup --user --yes >/dev/null 2>&1
SL="$S" jget "$settings" '$j->{statusLine}{padding} = 0; JSON::PP->new->utf8->canonical->encode($j)' >"$work/edited.json"
cp "$work/edited.json" "$settings"
ec=0; out="$(setup --user --remove --yes 2>&1)" || ec=$?
check "edited: the hook goes, the edited status line stays" '[ "$ec" = 0 ] && [ "$(hook_count "$settings" UserPromptSubmit "$H")" = 0 ] && [ "$(status_cmd "$settings")" = "$S" ]'
check "edited: says the status line still runs fdd statusline, remove it by hand" 'has "$out" "statusLine still runs fdd statusline" && has "$out" "remove it by hand"'
ec=0; out="$(setup --user --remove --yes 2>&1)" || ec=$?
check "edited, run again: names the status line, not nothing to remove" '[ "$ec" = 0 ] && has "$out" "statusLine still runs fdd statusline" && ! has "$out" "none of the entries"'
# The pair: setup's own status line goes, and a second run has nothing to remove.
fresh unedited
put '{}'
setup --user --yes >/dev/null 2>&1
setup --user --remove --yes >/dev/null 2>&1
ec=0; out="$(setup --user --remove --yes 2>&1)" || ec=$?
check "unedited: removed, and the next run says nothing to remove" '[ "$ec" = 0 ] && [ -z "$(status_cmd "$settings")" ] && has "$out" "none of the entries" && ! has "$out" "still runs fdd statusline"'

# 15. The wrapper advice never names a script of yours: it uses a name setup owns.
fresh own-script
mkdir -p "$HOME/.claude"
printf '#!/bin/bash\necho mine\n' >"$HOME/.claude/statusline.sh"
cp "$HOME/.claude/statusline.sh" "$work/own-script.orig"
put '{"statusLine":{"type":"command","command":"bash ~/.claude/statusline.sh"}}'
ec=0; out="$(setup --user --dry-run 2>&1)" || ec=$?
check "own script: the advice is not to save over ~/.claude/statusline.sh" '[ "$ec" = 0 ] && ! has "$out" "save this as ~/.claude/statusline.sh" && ! has "$out" "\"bash ~/.claude/statusline.sh\""'
check "own script: the advice names ~/.claude/fdd-statusline.sh" 'has "$out" "save this as ~/.claude/fdd-statusline.sh" && has "$out" "\"bash ~/.claude/fdd-statusline.sh\""'
check "own script: tools.md gives the same name" 'grep -qF "~/.claude/fdd-statusline.sh" "$tools" && ! grep -qF "save this as \`~/.claude/statusline.sh\`" "$tools"'
check "own script: your script is untouched" 'cmp -s "$HOME/.claude/statusline.sh" "$work/own-script.orig"'
# The status line already runs that name but lost the meter: add a line, do not overwrite.
fresh lost-meter
mkdir -p "$HOME/.claude"
printf '#!/bin/bash\necho mine\n' >"$HOME/.claude/fdd-statusline.sh"
put '{"statusLine":{"type":"command","command":"bash ~/.claude/fdd-statusline.sh"}}'
ec=0; out="$(setup --user --dry-run 2>&1)" || ec=$?
check "lost meter: says the script no longer calls fdd statusline, not to save over it" '[ "$ec" = 0 ] && has "$out" "already runs ~/.claude/fdd-statusline.sh" && ! has "$out" "save this as"'
# The status line names that script but it is not there: there is nothing to keep, so save it.
fresh no-wrapper
put '{"statusLine":{"type":"command","command":"bash ~/.claude/fdd-statusline.sh"}}'
ec=0; out="$(setup --user --dry-run 2>&1)" || ec=$?
check "missing wrapper: says save this as, not that it no longer calls the meter" '[ "$ec" = 0 ] && has "$out" "save this as ~/.claude/fdd-statusline.sh" && ! has "$out" "no longer calls the meter" && ! has "$out" "Do not save over it"'
# Another path that ends in fdd-statusline.sh is a script of yours, not setup's.
fresh other-wrapper
mkdir -p "$HOME/bin"
printf '#!/bin/bash\necho mine\n' >"$HOME/bin/fdd-statusline.sh"
put '{"statusLine":{"type":"command","command":"bash ~/bin/fdd-statusline.sh"}}'
ec=0; out="$(setup --user --dry-run 2>&1)" || ec=$?
check "other wrapper path: says save this as ~/.claude/fdd-statusline.sh" '[ "$ec" = 0 ] && has "$out" "save this as ~/.claude/fdd-statusline.sh" && ! has "$out" "no longer calls the meter"'

# 16. A read-only settings.json is refused like a symlink.
fresh readonly
put '{"a":1}'
chmod 444 "$settings"
cp "$settings" "$work/readonly.orig"
ec=0; out="$(setup --user --yes 2>&1)" || ec=$?
check "read-only: exits 1, says read-only, prints the keys to paste" '[ "$ec" = 1 ] && has "$out" "read-only" && has "$out" "$JH"'
check "read-only: file byte-identical, no backup, no temp file" 'cmp -s "$settings" "$work/readonly.orig" && [ "$(hook_count "$settings" UserPromptSubmit "$H")" = 0 ] && [ ! -e "$backups" ] && [ -z "$(strays)" ]'
ec=0; out="$(setup --user --remove --yes 2>&1)" || ec=$?
check "read-only: --remove with nothing to remove exits 0 and says so" '[ "$ec" = 0 ] && has "$out" "none of the entries" && ! has "$out" "read-only" && cmp -s "$settings" "$work/readonly.orig"'
chmod 644 "$settings"
# A read-only file that already has the meter needs no write, so it is not refused.
fresh readonly-on
put '{}'
setup --user --yes >/dev/null 2>&1
chmod 444 "$settings"
cp "$settings" "$work/readonly-on.orig"
nb_on="$(backup_count)"
ec=0; out="$(setup --user --yes 2>&1)" || ec=$?
check "read-only, meter on: exit 0, nothing to change, not refused" '[ "$ec" = 0 ] && has "$out" "Nothing to change: the meter is already on." && ! has "$out" "read-only" && cmp -s "$settings" "$work/readonly-on.orig"'
ec=0; out="$(setup --user --dry-run 2>&1)" || ec=$?
check "read-only, meter on: --dry-run exits 0 too" '[ "$ec" = 0 ] && has "$out" "Nothing to change" && ! has "$out" "read-only"'
ec=0; out="$(setup --user --remove --yes 2>&1)" || ec=$?
check "read-only, meter on: --remove would write, so it is refused" '[ "$ec" = 1 ] && has "$out" "read-only" && cmp -s "$settings" "$work/readonly-on.orig" && [ "$(backup_count)" = "$nb_on" ]'
check "read-only --remove: says how to turn the meter off by hand, not on" 'has "$out" "To turn the meter off by hand, delete these entries from $settings:" && has "$out" "$JH" && ! has "$out" "turn the meter on by hand"'
chmod 644 "$settings"
# The pair: refused in add mode, it says how to turn the meter on.
fresh readonly-add
put '{"a":1}'
chmod 444 "$settings"
ec=0; out="$(setup --user --yes 2>&1)" || ec=$?
check "read-only add: says how to turn the meter on by hand, not off" '[ "$ec" = 1 ] && has "$out" "To turn the meter on by hand, merge this into $settings:" && ! has "$out" "turn the meter off"'
chmod 644 "$settings"
# Symlink and invalid JSON refusals in remove mode say off as well.
fresh link-remove
mkdir -p "$HOME/.claude"
printf '{}\n' >"$work/link-remove.json"
ln -s "$work/link-remove.json" "$settings"
ec=0; out="$(setup --user --remove --yes 2>&1)" || ec=$?
check "symlink --remove: says turn the meter off by hand" '[ "$ec" = 1 ] && has "$out" "To turn the meter off by hand, delete these entries from" && ! has "$out" "turn the meter on by hand"'
fresh invalid-remove
put '{"a":'
ec=0; out="$(setup --user --remove --yes 2>&1)" || ec=$?
check "invalid --remove: says turn the meter off by hand" '[ "$ec" = 1 ] && has "$out" "To turn the meter off by hand" && has "$out" "$JS" && ! has "$out" "turn the meter on by hand"'
# The pair: a writable file with a narrow mode is written and keeps its mode.
fresh mode600
put '{"a":1}'
chmod 600 "$settings"
ec=0; out="$(setup --user --yes 2>&1)" || ec=$?
check "mode 600: written, and still mode 600" '[ "$ec" = 0 ] && [ "$(hook_count "$settings" UserPromptSubmit "$H")" = 1 ] && [ "$(perl -e "printf q(%o), (stat \$ARGV[0])[2] & 07777" "$settings")" = 600 ]'

# 17. Numbers keep their value through the rewrite, or the file is refused.
# same_number FILE VALUE: the file is valid JSON and .a is a number equal to VALUE.
same_number() { perl -MJSON::PP -MMath::BigFloat -e 'local $/; open my $f, "<", $ARGV[0] or exit 2; my $s = <$f>; my $j = eval { JSON::PP->new->utf8->allow_bignum->decode($s) } or exit 1; exit 1 if $s =~ /"a"\s*:\s*"/; exit(Math::BigFloat->new("$j->{a}")->bcmp(Math::BigFloat->new($ARGV[1])) == 0 ? 0 : 1)' "$1" "$2"; }
for v in 0.1234567890123456789 123456789012345678901234567890 1E400 18446744073709551616; do
  fresh "num-$v"
  put "{\"a\":$v}"
  cp "$settings" "$work/num.orig"
  ec=0; out="$(setup --user --yes 2>&1)" || ec=$?
  check "number $v: same value, or refused with the file unchanged" '{ [ "$ec" = 0 ] && same_number "$settings" "$v"; } || { [ "$ec" = 1 ] && cmp -s "$settings" "$work/num.orig" && has "$out" "number"; }'
done
fresh num-precise
put '{"a":0.1234567890123456789}'
ec=0; setup --user --yes >/dev/null 2>&1 || ec=$?
check "number: a long decimal is written, not refused" '[ "$ec" = 0 ] && same_number "$settings" 0.1234567890123456789 && [ "$(hook_count "$settings" UserPromptSubmit "$H")" = 1 ]'
# The pair: plain numbers are written as they were.
fresh num-plain
put '{"a":3,"b":0.5,"c":-2}'
ec=0; setup --user --yes >/dev/null 2>&1 || ec=$?
check "number: plain numbers are written and keep their value" '[ "$ec" = 0 ] && same_number "$settings" 3 && [ "$(jget "$settings" "\$j->{b}")" = 0.5 ] && [ "$(jget "$settings" "\$j->{c}")" = -2 ]'

# 18. The why line says the levels come sooner on a small window.
fresh why
ec=0; out="$(setup --user --dry-run 2>&1)" || ec=$?
check "why: the status line why gives both levels and says sooner on a small window" '[ "$ec" = 0 ] && has "$out" "yellow from 150k and red from 250k" && has "$out" "sooner on a small window"'

# 19. The new-sessions line comes once on every path that planned, never on usage errors.
nsl() { printf '%s\n' "$1" | grep -cF 'Applies to new sessions only'; }
fresh once
put '{}'
out="$(setup --user --yes 2>&1)"; check "once: --yes write says it once" '[ "$(nsl "$out")" = 1 ]'
out="$(setup --user --yes 2>&1)"; check "once: nothing to change says it once" '[ "$(nsl "$out")" = 1 ]'
out="$(setup --user --remove --dry-run 2>&1)"; check "once: --dry-run says it once" '[ "$(nsl "$out")" = 1 ]'
out="$(printf '' | setup --user --remove 2>&1)"; check "once: no answer says it once" '[ "$(nsl "$out")" = 1 ] && has "$out" "Nothing changed."'
out="$(printf 'n\n' | setup --user --remove 2>&1)"; check "once: n says it once" '[ "$(nsl "$out")" = 1 ]'
out="$(printf 'y\n' | setup --user --remove 2>&1)"; check "once: y says it once" '[ "$(nsl "$out")" = 1 ] && has "$out" "Saved"'
put '{"a":'
out="$(setup --user --yes 2>&1)"; check "once: invalid JSON says it once" '[ "$(nsl "$out")" = 1 ]'
out="$(setup --user --bogus 2>&1)"; check "once: an unknown option does not say it" '[ "$(nsl "$out")" = 0 ] && has "$out" "unknown option"'
out="$(setup --yes 2>&1)"; check "once: no --user does not say it" '[ "$(nsl "$out")" = 0 ] && has "$out" "--user"'
out="$(setup --help 2>&1)"; check "once: --help does not say it" '[ "$(nsl "$out")" = 0 ]'

# 20. A duplicate key is refused: the rewrite would keep only the last value.
for d in '{"env":{"A":"x"},"permissions":{"allow":["Bash(ls)"]},"env":{"B":"y"}}' '{"a":"x","a":"y"}' '{"o":{"k":1,"k":2}}' '{"l":[{"k":true},{"k":false,"k":null}]}'; do
  fresh dup
  put "$d"
  cp "$settings" "$work/dup.orig"
  ec=0; out="$(setup --user --yes 2>&1)" || ec=$?
  check "duplicate key $d: exits 1, says duplicate key, file unchanged, no backup" '[ "$ec" = 1 ] && has "$out" "duplicate key" && cmp -s "$settings" "$work/dup.orig" && [ ! -e "$backups" ]'
done
# The pair: the same key in different objects, and key-like text inside strings, are fine.
fresh no-dup
put '{"a":{"k":1},"b":{"k":2},"s":"\"a\": 1, \"a\": 2","l":[{"k":1},{"k":2}],"k":"x:y"}'
ec=0; out="$(setup --user --yes 2>&1)" || ec=$?
check "no duplicate: written, and every value kept" '[ "$ec" = 0 ] && [ "$(hook_count "$settings" UserPromptSubmit "$H")" = 1 ] && [ "$(jget "$settings" "\$j->{a}{k} . \$j->{b}{k} . \$j->{l}[1]{k} . \$j->{k}")" = "122x:y" ] && [ "$(jget "$settings" "\$j->{s}")" = "\"a\": 1, \"a\": 2" ]'

if [ "$fail" -eq 0 ]; then
  printf 'fdd setup: PASS\n'
  exit 0
fi
printf 'fdd setup: FAIL\n'
exit 1
