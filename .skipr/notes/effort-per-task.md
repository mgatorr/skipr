# effort-per-task

## Goal
models.md says which effort each task wants, and every skill skipr ships declares its own effort.

## Why
Effort is how thoroughly and how independently Claude works, not how smart it is; higher costs time and the human's say, so it is chosen per task, not left high.

## Questions closed
- Q: Which source? → A: Anthropic's effort guidance as retold in Fran Salazar's video "Anthropic reveló qué nivel de esfuerzo usar en Claude" (2026-11-02).
- Q: Skills set `model:` too? → A: No. A skill runs inside the session, and switching the model drops the cache; `effort:` does not. Models are set per agent. (2026-11-02)
- Q: Raise the models.md cap? → A: Yes, 50 → 60, for the effort section. (2026-11-02)

## Out of scope
- Changing the installer, settings.json or the user's default effort.
- `model:` in any skill.

## Slices
- [x] 1. check-docs fails when a tracked `SKILL.md` has no `effort:` in its front matter; the five skipr skills declare one.
- [x] 2. models.md: an Effort column, an `## Effort` section with the four questions, `effort:` in the agent example; cap 60.

## Checks
- 1 and 2: `bash scripts/test-check-docs.sh` and `bash scripts/check-docs.sh` on /bin/bash.

## Evidence
- 2026-11-02, /bin/bash: `test-check-docs.sh` PASS (it failed first on the 60 cap and the missing effort), `check-docs.sh` docs check ok, models.md 60 lines. The other script tests pass except install-macos scenario 8, which clones HEAD and so differs until this is committed: rerun it after the commit.

## Next
Commit with `fdd commit`, then rerun `bash scripts/test-install-macos.sh` (scenario 8 needs the commit).
