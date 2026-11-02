# effort-per-task

## Goal
models.md says which effort each task wants, and every skill skipr ships declares its own effort.

## Why
Effort is how thoroughly and how independently Claude works, not how smart it is; higher costs time and the human's say, so it is chosen per task, not left high.

## Questions closed
- Q: Which source? → A: Anthropic's guidance on effort levels, as retold in a talk on choosing effort per task (2026-11-02).
- Q: Skills set `model:` too? → A: No. A skill runs inside the session, and switching the model drops the cache; `effort:` does not. Models are set per agent. (2026-11-02)
- Q: Raise the models.md cap? → A: Yes, 50 → 60, for the effort section. (2026-11-02)

## Out of scope
- Changing the installer, settings.json or the user's default effort.
- `model:` in any skill.

## Slices
- [x] 1. check-docs fails when a tracked `SKILL.md` has no `effort:` in a closed frontmatter block (CRLF, quotes and a trailing comment are fine; quotes must be paired and a comment needs a space before `#`); a missing or unreadable file is skipped so its path is never printed; the five skipr skills declare one.
- [x] 2. models.md: an Effort column, an `## Effort` section with the four questions, `effort:` in the agent example; cap 60.

## Checks
- 1 and 2: `bash scripts/test-check-docs.sh` and `bash scripts/check-docs.sh` on /bin/bash.

## Evidence
- 2026-11-02, /bin/bash: `test-check-docs.sh` PASS (it failed first on the 60 cap and the missing effort), `check-docs.sh` docs check ok, models.md 60 lines. The other script tests pass; install-macos (scenario 8 clones HEAD) passes once committed. After review: four mutants of the awk (any value, no first-line `---`, no closing `---`, `effort:high`) each make test-check-docs FAIL.

## Next
Merge PR #26.
