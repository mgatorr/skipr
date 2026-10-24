---
name: fdd
description: Use when building with Fast Driven Development — explore, a short note, vertical slices, a check that can fail, and a preview to review the build. Default protocol for Claude Code. Fast Driven Development, not Feature-Driven Development.
---

# FDD · Fast Driven Development

FDD here means Fast Driven Development. It is not Feature-Driven Development.

Default way of working for one person who builds with agents. It replaces the spec, plan, and tasks chain. It is not a document generator.

One flow for everyone. Claude Code first.

## Flow

1. **Idea.** The human asks for an outcome in one or two sentences.
2. **Explore.** Read the code, `.skipr/rules.md`, and search `.skipr/logbook/` (`rg -i "<term>" .skipr/logbook/`, start at `INDEX.md`) before asking anything.
3. **Size it.**
   - **1 step:** do it, run its check, go to Close. No note.
   - **2+ steps:** open a note.
4. **Close the questions in a short note.** Copy [`templates/note.md`](./templates/note.md) to `.skipr/notes/<feature>.md`. Ask **one question at a time**, and only about a real decision you cannot get from the code, the rules, or the logbook. Record each answer in the note. Once the note has a goal, closed questions, out of scope, and at least one check, start building. The human does not have to approve the note.
5. **Build fast, slice by slice.** Each slice is vertical and can be used or looked at quickly. Per slice: write a check that fails, make it pass, small commit (`fdd commit`). Where a test runner exists, the test goes in its own commit before the code. A slice has at most 3 given/when/then lines. Tick a box only when there is evidence. Do not put technical design in the note.
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

## Undo (`fdd undo`)

Each turn is a snapshot of the working tree, taken by two Claude Code hooks. `fdd undo` puts the files back one turn; `fdd redo` goes forward. HEAD, branches and the staging area never change, and ignored files, secret-looking files (`.env*`, keys) and untracked files over 100 MB are never saved or written. When the human asks to undo a turn, run `~/.claude/skills/fdd/bin/fdd undo` and say what came back. Setup and limits: [`tools.md`](./tools.md).

## Context (`fdd statusline`)

One slice per clean session. The status line shows how full the context window is. At 50%, do not start a new slice: finish the current one, then suggest `/compact`. At 75%, finish the slice, write where it stands in the note's `Next` line, and tell the human to start a new session. The prompt hook says this once per threshold to the human and to you. Setup: [`tools.md`](./tools.md).

## Commit (`fdd commit`)

Per slice, commit with `~/.claude/skills/fdd/bin/fdd commit "type(scope): summary" -- <files>`. It takes Conventional Commits only, refuses staged secrets (gitleaks when installed, plus well-known key shapes), drops any Claude attribution, adds the owner's co-author from `git config fdd.coauthor`, and never pushes unless `--push`. Details: [`tools.md`](./tools.md).

## Models

Which model for which step: [`models.md`](./models.md). Starting points; a check decides, not taste.

## Templates

- [`templates/note.md`](./templates/note.md) — the short note
- [`templates/rules.md`](./templates/rules.md) — layer 1 line format
- [`templates/logbook-entry.md`](./templates/logbook-entry.md) — one closed feature
- [`templates/logbook-index.md`](./templates/logbook-index.md) — one line per feature
- [`templates/claude-settings.json`](./templates/claude-settings.json) — the hooks and status line for `fdd`, merged into a project's `.claude/settings.json`
