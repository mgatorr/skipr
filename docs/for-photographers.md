# skipr for photographers

You already try Claude in the app. skipr is the next step: **a real folder, short rails, and a check that can say no.** Not 400 skills. Not a Second Brain vault.

English is the product language. One-line Spanish pointer: [es/for-photographers.md](./es/for-photographers.md).

## The harness (the promise)

A harness is two things:

1. A short `CLAUDE.md` — a handful of rules the agent must follow
2. A script under `checks/` that can **fail**

If it cannot say *no*, it is not a harness. It is a prompt dump.

## App vs console

The Claude **app** is a chat. skipr uses **Claude Code** in a terminal, opened **inside your project folder**.

- The terminal is **taught, not hidden**. [Ghostty](https://ghostty.org) is optional and calm; Terminal.app / iTerm are fine.
- Work in the trip / client / culling folder — not a generic notes vault hoping the agent finds the photos.

```bash
cd ~/Projects/viaje-lisboa
claude
```

## Less skills, more checks

Skills tell the agent what to try. Checks prove whether the job is done.

skipr installs **at most two** local skills. Extra rules go in one line of `CLAUDE.md` or a new checker — never a hoard.

| Job | Default check |
|---|---|
| Trip (`viaje`) | `./checks/naming.sh` |
| Client | `./checks/brief-ready.sh` |
| Culling | `./checks/naming.sh` |
| Delivery | `./checks/delivery.sh` |

## One project = one folder

Lisbon trip, a wedding, a cull session — each is its own directory. The agent stays there. It does not invent EXIF, dates, or deliverables. It does not delete originals.

## Two-minute fail/pass (no Claude yet)

Clone (or unzip) this repo, then:

```bash
git clone https://github.com/mgatorr/skipr.git
cd skipr/examples/photo-trip
./checks/naming.sh
```

It fails on purpose on a loose `IMG_0042.JPG`. How to pass: [photo-trip fail/pass](../examples/photo-trip/checks/README.md#fail-then-pass-the-first-win). Sample folder: [`examples/photo-trip`](../examples/photo-trip/).

## Ten-minute first win (your own folder)

1. Install the [Claude Code CLI](https://code.claude.com/docs/en/install) (`claude --version`) — not only the desktop app.
2. Copy [`skills/setup-harness/`](../skills/setup-harness/) to `~/.claude/skills/setup-harness/`.
3. `cd` into a trip or client folder, run `claude`, ask: *Run setup-harness for this folder*.
4. Run the checker it installed. Green or a clear red — both are a win.

Same files without Claude: copy `skills/setup-harness/templates/` into the trip folder, `chmod +x checks/*.sh`, and run a checker. Details: [novice-guide — manual copy](./novice-guide.md#manual-copy-no-claude-yet).

Full beginner path: [novice-guide.md](./novice-guide.md). The skill itself: [`skills/setup-harness/SKILL.md`](../skills/setup-harness/SKILL.md).

---

*skipr is independent and not affiliated with Anthropic.* “Claude” and “Claude Code” are trademarks of their respective owner. Ghostty is a trademark of its respective owner.
