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
- [ ] 2. The installer offers the meter at user level, [Y/n], backup-first (provisional).
- [ ] 3. Photo folders get the meter through `--warn-only`, never snapshots (provisional).
- [ ] 4. The novice guide teaches the meter and `/clear` (provisional).
- [ ] 5. Subagents and workflows get their model and effort per agent (provisional).

## Checks
- 1: `bash scripts/test-fdd-context.sh` on /bin/bash (and /opt/homebrew/bin/bash when present).
- 2: `bash scripts/test-install-macos.sh` with a case for the meter prompt and the backup.
- 3: `bash scripts/test-harness-checks.sh` with a case that the photo setup adds no snapshot hook.
- 4: `scripts/check-docs.sh` with the real list, plus a test that the guide quotes the thresholds.
- 5: a docs test that models.md names per-agent model and effort.
- Every slice: `DOCS_BANNED=... GITHUB_ACTIONS=true bash scripts/check-docs.sh`.

## Evidence
- 1: `/bin/bash scripts/test-fdd-context.sh` → `fdd context: PASS` (2026-10-26; 15 repeat runs, 0 failures; failed against the old bin/fdd at ba447e4). /opt/homebrew/bin/bash is not installed here.
- 1: `/bin/bash scripts/test-fdd-undo.sh` and `test-fdd-commit.sh` → PASS; check-docs with the real list → `docs check ok`.
- 1: with no token figure the line shows the percentage and a dim `?`; the hook then gives no warning (no stale count).

## Next
Slice 2: the installer offers the meter at user level (`fdd hook --warn-only`), [Y/n], backup-first.
