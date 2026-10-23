---
name: fdd
description: Use when building with Fast Driven Development — explore, a short note, vertical slices, a check that can fail, and a preview to review the build. Default protocol for Claude Code.
---

# FDD · Fast Driven Development

Default way of working for one person who builds with agents. It replaces the spec, plan, and tasks chain. It is not a document generator.

One flow for everyone. Claude Code first.

## Flow

1. **Idea.** The human asks for an outcome in one or two sentences.
2. **Explore.** Read the code, `.skipr/rules.md`, and search `.skipr/logbook/` (`rg -i "<term>" .skipr/logbook/`, start at `INDEX.md`) before asking anything.
3. **Size it.**
   - **1 step:** do it, run its check, go to Close. No note.
   - **2+ steps:** open a note.
4. **Close the questions in a short note.** Copy [`templates/note.md`](./templates/note.md) to `.skipr/notes/<feature>.md`. Ask **one question at a time**, and only about a real decision you cannot get from the code, the rules, or the logbook. Record each answer in the note. Once the note has a goal, closed questions, out of scope, and at least one check, start building. The human does not have to approve the note.
5. **Build fast, slice by slice.** Each slice is vertical and can be used or looked at quickly. Per slice: write a check that fails, make it pass, small commit. Where a test runner exists, the test goes in its own commit before the code. A slice has at most 3 given/when/then lines. Tick a box only when there is evidence. Do not put technical design in the note.
6. **Reproduce.** A different agent from the author tries to break the result by reproducing it. Opinions are not a review.
7. **Review room.** The human looks at a preview to review the build. They approve it or leave comments. Comments send the work back to step 5.
8. **Close.** Distill the note into `.skipr/logbook/<feature>.md` (≤ 40 lines) and one line in `.skipr/logbook/INDEX.md`. Append any new rule to `.skipr/rules.md`. Delete the note.

Done means a check that can fail has passed, its evidence is in the note, and the human has approved in the review room.

## Rules (layer 1)

`.skipr/rules.md` is ≤ 40 lines, one rule per line, loaded every session from `@.skipr/rules.md` in `CLAUDE.md`.

Format: `- <rule> (<source>, <YYYY-MM-DD>, <feature>)`

At close, classify each review-room comment:

- **One-off fix:** fix it and add no rule.
- **Would apply again:** append one rule line. If a check can enforce it, add the check and point the line at it.
- **Same correction a second time:** rewrite the rule or turn it into a check. Do not repeat it.

At the cap, merge or delete before adding. A rule covered by a check can shrink to `see <check>`. A logbook entry never overrides `.skipr/rules.md`. Promote a decision only when it should apply everywhere.

## Logbook (layer 2)

Not loaded by default. Search it during Explore, or when a question touches an earlier feature. Plain text in git. No memory server, database, or embeddings.

## Note

One note per feature, ≤ 60 lines, thrown away at close. It is the handoff for a cloud or background agent. Template: [`templates/note.md`](./templates/note.md).
