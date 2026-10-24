# fdd-post-p0

## Goal and outcome
The four post-P0 items the owner approved: `fdd undo`, context warnings at 50/75%, `fdd commit` without push, and model per task as a doc. One bash script, `skills/fdd/bin/fdd`, with a test per item.

## Decisions
- One script in the skill folder, not a plugin: the installer already copies it, and it runs on the bash 3.2 that ships with macOS. (2026-10-24)
- Snapshots live in per-worktree refs (`refs/worktree/fdd/<n>`) and a throwaway index, so HEAD, branches, staging and other worktrees never see them. (2026-10-24)
- Secret-looking files are left out of snapshots even when `.gitignore` misses them. (2026-10-24)
- Hooks get no context figure; the status line does. The status line keeps the figure per session and the prompt hook warns once per threshold, to the human and to the model. (2026-10-24)
- `fdd commit` runs gitleaks and its own key patterns together, so a gitleaks that errors out does not let a key through. (2026-10-24)

## Closed questions worth keeping
- Q: Does Claude Code expose context use to hooks? → A: No; only the status line gets `context_window.used_percentage`. (2026-10-24)
- Q: Does `git read-tree -m -u` protect ignored files? → A: No, it writes over them. `fdd` checks every added path against the disk first. (2026-10-24)

## Rejected options
- Copying the index with plain `cp`: the new mtime made git trust stale stat data and 19 of 300 snapshots lost a same-size edit. `cp -p` keeps it; the test runs the race 100 times.
- Numbered undo (go to n-1): after an undo and a new turn it went back into the undone branch. Undo follows the snapshot's parent.

## Review-room corrections
None yet.

## Follow-ups
- The owner checks the meter and the warning in his own terminal.
- setup-harness does not turn on the `fdd` hooks: in a photo folder the first snapshot would copy every unignored photo into `.git`. Decided 2026-10-24; revisit only with a total-size guard.

## Links
- Tests: `scripts/test-fdd-undo.sh`, `scripts/test-fdd-commit.sh`, `scripts/test-fdd-context.sh`
