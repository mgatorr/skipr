# Checks (photo-trip)

Scripts that can fail. If they cannot say **no**, they are not checks.

This example ships **one** checker: naming. Empty `.jpg` / `.JPG` files here are
placeholders — the names are the point, not the pixels.

## How to run

```bash
./checks/naming.sh
```

Exit code: `0` = ok, non-zero = fix something (rename or move; do not delete).

## Fail, then pass (the first win)

This folder is committed in the **fail** state on purpose.

1. From `examples/photo-trip/`, run `./checks/naming.sh`.
   It must fail on the loose camera dump `IMG_0042.JPG` at the project root.
2. Move that file into the dated shoot folder (rename optional):

   ```bash
   mv IMG_0042.JPG 2026-09-01-porto/
   ```

3. Re-run `./checks/naming.sh`. It must print `✓ naming ok`.

The files under `2026-09-01-porto/` already use date-prefixed names so the pass
path is real, not a mocked script.

To restore the demo fail: `mv 2026-09-01-porto/IMG_0042.JPG .`

Then ask the agent in Claude Code: “the checker failed — fix it without deleting
originals.” If the checker cannot fail, the setup is wrong.
