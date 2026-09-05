# Photo trip — Porto (example)

Work folder: **viaje / trip**. Stay in this directory. Do not wander into a generic vault.

## Language

- Code, paths, commits, and file renames: **English / ASCII**.
- Replies to the human: **en**.
- Working language: en

## Rules

- Do not invent EXIF, GPS, dates, clients, or deliverables. If data is missing, ask.
- If `BRIEF.md` is missing or empty, ask before guessing the trip.
- Do not delete original photos or folders. If cleanup is needed, propose and wait.
- Prefer `checks/` over adding new skills. If a rule keeps coming up, tighten one line here
  or one checker — do not grow a skill hoard.
- Before saying “done”, run `./checks/naming.sh` and fix failures.

## Checkers

```bash
./checks/naming.sh
```

Only run checkers that exist in this folder.

## Done means

The checker exits green **and** the human confirms by looking at files, not only by reading
what the model claims.
