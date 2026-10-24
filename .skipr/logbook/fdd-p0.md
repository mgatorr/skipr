# fdd-p0

## Goal and outcome
Replace the spec-plan-tasks chain with Fast Driven Development. The old tree is gone. Tag `era-spec-kit` keeps it. This repo now has rules and a logbook.

## Decisions
- Two layers, `rules` (always loaded) and `logbook` (search on demand), so close can keep a decision without growing the rules. (2026-10-23)
- English only. Translated mirrors and Spanish harness names are removed. The Spanish status block was deleted, not translated. (2026-10-23)
- Public text calls the review room a preview to review the build. (2026-10-23)
- Credits name no other tool. (2026-10-23)
- The previous spec gate is a local hook outside this repo. Retire it after 3 features or 2 weeks, whichever comes first. The first feature is the review room. (2026-10-23)

## Closed questions worth keeping
- Q: Memory names? → A: `rules` and `logbook`. (2026-10-23)
- Q: Tag the old era? → A: annotated tag `era-spec-kit` on `52e0e40`. (2026-10-23)

## Rejected options
- One memory file, or other names for the two layers.
- Keeping translated mirrors next to the English docs.
- A credit line that names another method.

## Review-room corrections
None yet. This change has not been approved in a preview.

## Follow-ups
- Trial starts with the review room, then two more features or the rest of two weeks.
- Do not merge or publish from this work.

## Links
- Tag `era-spec-kit` (`52e0e40`)
- PR: https://github.com/mgatorr/skipr/pull/18 (cleanup)
- PR: https://github.com/mgatorr/skipr/pull/19 (method, stacked on the cleanup branch)
- Preview: none yet
