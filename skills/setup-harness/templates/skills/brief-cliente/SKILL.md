---
name: brief-cliente
description: Use when drafting or completing BRIEF.md for a client photo job in this folder — sections Client, Date, Deliverables, tone/use; never invent missing facts. Spanish heading aliases (Cliente/Fecha/Entregables) are accepted by the checker.
---

# Client brief

Create or complete `BRIEF.md` in the project root.

## Required sections (English headings — canonical)

```markdown
# Brief

## Client
## Date
## Deliverables
## Tone / use
## Notes
```

Legacy Spanish headings (`Cliente`, `Fecha`, `Entregables`, `Tono / uso`, `Notas`) are still
accepted by `./checks/brief-ready.sh`. Prefer English when the project Working language is `en`.

## Rules

- Ask for any missing fact. Do not invent client names, dates, or deliverables.
- Keep it short (one screen).
- After writing, run `./checks/brief-ready.sh` and fix until green.
