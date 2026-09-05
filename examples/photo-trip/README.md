# photo-trip (first win)

A tiny trip folder you can **fail, then pass**, before opening Claude.

Empty `.jpg` / `.JPG` files here are **placeholders on purpose** — the names
are the point, not the pixels.

## Fail, then pass

```bash
git clone https://github.com/mgatorr/skipr.git
cd skipr/examples/photo-trip
./checks/naming.sh
```

It must fail on the loose `IMG_0042.JPG` at the project root. Move that file
into `2026-09-01-porto/`, re-run, and you should see `✓ naming ok`.

Step-by-step: [checks/README.md](./checks/README.md#fail-then-pass-the-first-win).

This is the same harness as [setup-harness](../../skills/setup-harness/), not a
second product path.
