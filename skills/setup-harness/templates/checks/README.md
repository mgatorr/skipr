# Checks

Scripts that can fail. If they cannot say **no**, they are not checks.

Messages stay English. BRIEF headings accept English (`Client`, `Date`, `Deliverables`) or Spanish (`Cliente`, `Fecha`, `Entregables`), including a title on that line (`# Client: Acme Studio`, `# Cliente: Acme Studio`). `deliverables/` and `entregables/` are both accepted.

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
3. **delivery:** remove `deliverables/` or leave it empty and run `./checks/delivery.sh`.

Then ask the agent in Claude Code: “the checker failed — fix it without deleting originals.”
If the checker cannot fail, the setup is wrong.
