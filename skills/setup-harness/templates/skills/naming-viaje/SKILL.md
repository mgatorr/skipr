---
name: naming-viaje
description: Use when renaming trip photo folders or files in this project — date-prefixed folders YYYY-MM-DD, no loose IMG_/DSC_ at root; never delete originals.
---

# Naming viaje

## Conventions

- Top-level shoot folders: `YYYY-MM-DD-slug` (example: `2026-08-24-glenfinnan`)
- Prefer moving camera dumps *into* dated folders rather than renaming thousands
  of files on day one
- Never delete originals; quarantine only with explicit human OK

## Workflow

1. Run `./checks/naming.sh`
2. Fix failures (rename / move)
3. Re-run until green
