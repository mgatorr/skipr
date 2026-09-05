# Examples

First-wins you can **clone, `cd` into, and run**. Each folder is a tiny project with a short
`CLAUDE.md` and a `checks/` script that is allowed to say **no**.

This is not a new skipr product surface. It is a concrete harness you can see fail and pass
before you install [setup-harness](../skills/setup-harness/) on your own trip folder.

The terminal is taught, not hidden. skipr is independent and **not affiliated with Anthropic**.

## How to use

1. Clone this repository (or download a zip and unzip it):

   ```bash
   git clone https://github.com/mgatorr/skipr.git
   cd skipr
   ```

2. Enter one example folder and run its checker:

   ```bash
   cd examples/photo-trip
   ./checks/naming.sh
   ```

   Red with a clear message is a win — the rails work. Green after you fix the folder is the
   other win. See [photo-trip](./photo-trip/) for the fail/pass demo.

3. Open Claude Code **in that same folder** (not a generic vault):

   ```bash
   claude
   ```

   Ask it to read `CLAUDE.md`, run `./checks/naming.sh`, and fix failures without deleting
   originals.

## What’s here

| Folder | Domain | Checker | What you should see |
|---|---|---|---|
| [`photo-trip/`](./photo-trip/) | trip / viaje | `./checks/naming.sh` | Fails on a loose `IMG_####` name; passes after you move it into the dated folder |

More examples can land later. Prefer a new folder with one check over extra skills.
