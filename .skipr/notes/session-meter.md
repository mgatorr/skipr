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
- [x] 4. The novice guide teaches one task per session, the meter and `/clear`; check-docs caps that section at 20 lines and wants `/clear` in the harness template.
- [x] 5. models.md teaches model and effort per agent, the start cost, fork vs fresh agent and the cache; check-docs caps the file at 50 and the section at 12.

## Checks
- 1: `bash scripts/test-fdd-context.sh` on /bin/bash (and /opt/homebrew/bin/bash when present).
- 2: `bash scripts/test-fdd-setup.sh` on /bin/bash (CI: harness-checks and install-macos-test).
- 3: `bash scripts/test-install-macos.sh` scenarios 14-20, plus `setup --help` in test-fdd-setup.sh.
- 4: `scripts/check-docs.sh` with the real list, plus a test that the guide quotes the thresholds.
- 5: `scripts/check-docs.sh` wants `## Agents and workflows` in models.md (at most 12 lines) and caps the file at 50; test-check-docs.sh case 13.
- Every slice: `DOCS_BANNED=... GITHUB_ACTIONS=true bash scripts/check-docs.sh`.

## Evidence
- 1: `/bin/bash scripts/test-fdd-context.sh` → `fdd context: PASS` (2026-10-26; 15 repeat runs, 0 failures; failed against the old bin/fdd at ba447e4). /opt/homebrew/bin/bash is not installed here.
- 1: `/bin/bash scripts/test-fdd-undo.sh` and `test-fdd-commit.sh` → PASS; check-docs with the real list → `docs check ok`.
- 1: with no token figure the line shows the percentage and a dim `?`; the hook then gives no warning (no stale count).
- 2: `/bin/bash scripts/test-fdd-setup.sh` → `fdd setup: PASS`, 66 checks (2026-10-26; 10 repeat runs, 0 failures; 48 failed against the code before it). Mutations caught: no race re-check, no backup copy, duplicate hooks, empty entries kept, snippet drift from tools.md.
- 2: test-fdd-context, -undo, -commit, test-check-docs(-provenance) → PASS; check-docs with the real list → `docs check ok`. /opt/homebrew/bin/bash not installed.
- 3: `/bin/bash scripts/test-install-macos.sh` → `installer scenarios: PASS`, 19 scenarios (2026-10-26; 14-19 and `setup --help` failed at 1c1d5b6). Mutations caught: no probe (18), dry-run writes (16), flag ignored (14, 16-19).
- 3: by hand through a pty (`script`): empty answer to `[Y/n]` wrote settings.json, `n` wrote nothing. Other tests and check-docs → PASS. Not run on Linux here.
- 4: `/bin/bash scripts/test-check-docs.sh` → `check-docs redaction: PASS` (2026-10-26). At ef7a90d the 21-line, missing-heading and no-`/clear` fixtures failed; with the new check and before the docs, the real tree failed (missing heading, missing /clear). Mutations caught: cap 21, section not ended by `## `, trailing `---` counted, wrong template string.
- 4: `test-fdd-context.sh` now also checks docs/novice-guide.md (150k, 250k, no 50% or 75%) → PASS; failed at ef7a90d. Other tests and check-docs with the real list → PASS. Only BSD awk here; mawk and gawk not run.
- 5: `/bin/bash scripts/test-check-docs.sh` → PASS (2026-10-26). At 8d0fc84 the 51-line, missing-heading and 13-line fixtures failed; with the new check and before the docs, the real tree failed (missing heading). Mutations caught: section cap 13, file cap 51, section check removed.
- 5: all 12 scripts/test-*.sh on /bin/bash → PASS; check-docs with the real list → `docs check ok`. models.md is 47 lines. /opt/homebrew/bin/bash not installed.
- Repro fixes (2026-10-26), each test committed first and seen failing (1ae6d9b..c6b6093): `--remove` drops an entry it empties, matcher and all; names an edited status line that still runs the meter instead of "nothing to remove"; the wrapper is `~/.claude/fdd-statusline.sh`, never a script of yours; a read-only settings.json is refused; numbers keep their value (allow_bignum) or the file is refused (2^64, 1e5000); red says "sooner on a small window" in the guide and the why line; the new-sessions line comes once, never on usage errors.
- Repro fixes: `/bin/bash scripts/test-fdd-setup.sh` → `fdd setup: PASS`, 102 checks, 5 repeat runs; all 12 scripts/test-*.sh → PASS; check-docs with the real list → `docs check ok`. /opt/homebrew/bin/bash not installed.
- Round 2 (2026-10-26), each test committed first and seen failing (acd5d4b..0b62268): a read-only file is refused only when the plan writes (meter already on → exit 0); `--remove` refusals say how to turn the meter off; a duplicate key is refused; a missing or foreign-path fdd-statusline.sh gets the save advice; the installer shows the plan and the new-sessions line once on a yes run (scenario 20).
- Round 2: `/bin/bash scripts/test-fdd-setup.sh` → PASS, 116 checks, 5 repeat runs; `test-install-macos.sh` → 20 scenarios PASS; all 12 scripts/test-*.sh → PASS; check-docs with the real list → `docs check ok`. /opt/homebrew/bin/bash not installed.

## Next
All five slices are done: the branch is ready for the review room, after a different agent reproduces it. Still open from the old slice 3: photo folders get the meter through `--warn-only`, never snapshots.
