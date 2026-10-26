# session-meter

## Goal
The context meter warns in absolute tokens, not percent, and reaches novices.

## Why
Every message re-sends the whole context, and on a 1M window 18% is already 182k tokens per message.

## Questions closed
- Q: Does the installer offer the session meter? → A: Yes, default yes ([Y/n]). (2026-10-26)
- Q: `fdd checkup` in this batch? → A: No, deferred. (2026-10-26)
- Q: Set autoCompactWindow? → A: Not in v1. (2026-10-26)
- Q: Handoff file, SessionStart hook or idle warning? → A: None of them. (2026-10-26)
- Q: Which status line keys hold the tokens? → A: Claude Code 2.1.310 sends `context_window.total_input_tokens` (input + cache creation + cache read), `total_output_tokens`, `context_window_size`, `current_usage`, `used_percentage`, `remaining_percentage`. Pinned in the test fixtures. (2026-10-26)

## Out of scope
- `fdd checkup`, autoCompactWindow, a handoff file, a SessionStart hook, an idle warning.
- Reading transcripts, blocking a prompt.

## Slices
- [x] 1. The meter counts tokens: status line, hook warnings once per level, `fdd hook --warn-only`, SKILL.md and tools.md.
- [x] 2. `fdd setup --user` turns the meter on in `~/.claude/settings.json`, backup first; `--remove` takes it out.
- [x] 3. The installer offers the meter: plan first, `[Y/n]` yes by default, `--with-session-meter` when nothing can ask; an older kept fdd skill is warned and skipped.
- [ ] 4. The novice guide teaches the meter and `/clear` (provisional).
- [ ] 5. Subagents and workflows get their model and effort per agent (provisional).

## Checks
- 1: `bash scripts/test-fdd-context.sh` on /bin/bash (and /opt/homebrew/bin/bash when present).
- 2: `bash scripts/test-fdd-setup.sh` on /bin/bash (CI: harness-checks and install-macos-test).
- 3: `bash scripts/test-install-macos.sh` scenarios 14-19, plus `setup --help` in test-fdd-setup.sh.
- 4: `scripts/check-docs.sh` with the real list, plus a test that the guide quotes the thresholds.
- 5: a docs test that models.md names per-agent model and effort.
- Every slice: `DOCS_BANNED=... GITHUB_ACTIONS=true bash scripts/check-docs.sh`.

## Evidence
- 1: `/bin/bash scripts/test-fdd-context.sh` → `fdd context: PASS` (2026-10-26; 15 repeat runs, 0 failures; failed against the old bin/fdd at ba447e4). /opt/homebrew/bin/bash is not installed here.
- 1: `/bin/bash scripts/test-fdd-undo.sh` and `test-fdd-commit.sh` → PASS; check-docs with the real list → `docs check ok`.
- 1: with no token figure the line shows the percentage and a dim `?`; the hook then gives no warning (no stale count).
- 2: `/bin/bash scripts/test-fdd-setup.sh` → `fdd setup: PASS`, 66 checks (2026-10-26; 10 repeat runs, 0 failures; 48 failed against the code before it). Mutations caught: no race re-check, no backup copy, duplicate hooks, empty entries kept, snippet drift from tools.md.
- 2: test-fdd-context, -undo, -commit, test-check-docs(-provenance) → PASS; check-docs with the real list → `docs check ok`. /opt/homebrew/bin/bash not installed.
- 3: `/bin/bash scripts/test-install-macos.sh` → `installer scenarios: PASS`, 19 scenarios (2026-10-26; 14-19 and `setup --help` failed at 1c1d5b6). Mutations caught: no probe (18), dry-run writes (16), flag ignored (14, 16-19).
- 3: by hand through a pty (`script`): empty answer to `[Y/n]` wrote settings.json, `n` wrote nothing. Other tests and check-docs → PASS. Not run on Linux here.

## Next
Slice 4: the novice guide teaches the meter and `/clear`. Still open from the old slice 3: photo folders get the meter through `--warn-only`, never snapshots.
