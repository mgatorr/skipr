# {{PROJECT_NAME}}

Work folder: **{{DOMAIN}}**. The agent stays in this directory — not a generic vault.

## Language

- Code, paths, commits, and file renames: **English / ASCII**.
- Replies to the human: **{{LANG}}** (default `en`; set to `es` if preferred).
- Working language line (agents read this): `Working language: {{LANG}}`

## Rules

- Do not invent EXIF, GPS, dates, clients, or deliverables. If data is missing, ask.
- Do not delete original photos or folders. If cleanup is needed, propose and wait for OK.
- Before saying “done”, run the matching checker under `checks/` and fix failures.
- Keep this file short. If it grows, trim it — do not add a Second Brain.

## Checkers

```bash
./checks/naming.sh        # viaje / culling
./checks/brief-ready.sh   # cliente
./checks/delivery.sh      # delivery
```

Only run checkers that exist in this folder.

## Done means

The checker exits green **and** the human confirms by looking at files (or the screen),
not only by reading what the model claims.
