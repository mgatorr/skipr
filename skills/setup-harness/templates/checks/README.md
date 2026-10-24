# Checks

Scripts that can fail. If they cannot say **no**, they are not checks.

Messages stay English. In a user project, Spanish headings are accepted: `Cliente`, `Fecha` (or `Fecha de entrega`), and `Entregables`, as the whole word, alone or as a title (`# Cliente: Acme Studio`). English headings (`Client`, `Date` or `Delivery date`, `Deliverables`) are accepted the same way, and so is the field style `**Client:** Acme Studio`. A required section with nothing under it fails. `deliverables/` and `entregables/` are both accepted; `MANIFEST.md` alone is not a delivery.

Camera default names fail at the project root and inside the delivery, any case: `IMG_`, `_MG_` (Canon, iPhone), `DSC`, `_DSC`, `DSC_` (Sony, Nikon), `DSCF` (Fuji), `DJI_` (DJI), `GOPR`, `GH`, `GX` (GoPro).

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
2. **brief:** delete `BRIEF.md`, or leave a heading like `## Date` with nothing under it, and run `./checks/brief-ready.sh`.
3. **delivery:** remove `deliverables/` or leave it empty and run `./checks/delivery.sh`.

Then ask the agent in Claude Code: “the checker failed — fix it without deleting originals.”
If the checker cannot fail, the setup is wrong.
