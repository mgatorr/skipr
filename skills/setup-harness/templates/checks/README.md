# Checks

Scripts that can fail. If they cannot say **no**, they are not checks.

**Default language:** English messages and BRIEF headings (`Client`, `Date`, `Deliverables`).
Spanish messages activate when `Working language: es` / `SKIPR_LOCALE=es` / `LANG=es*`
(legacy Spanish BRIEF headings `Cliente` / `Fecha` / `Entregables` are still accepted).

## How to run

```bash
./checks/naming.sh
./checks/brief-ready.sh
./checks/delivery.sh
```

Exit code: `0` = ok, non-zero = fix something.

## Break on purpose (to see the harness work)

1. **naming:** leave a loose `IMG_0001.JPG` at the project root (or a photo folder without a
   `YYYY-MM-DD` prefix) and re-run `./checks/naming.sh`. It must fail.
2. **brief:** delete or empty `BRIEF.md` and run `./checks/brief-ready.sh`.
3. **delivery:** remove `deliverables/` (or legacy `entregables/`) or leave it empty and run
   `./checks/delivery.sh`.

Then ask the agent in Claude Code: “the checker failed — fix it without deleting originals.”
If the checker cannot fail, the setup is wrong.
