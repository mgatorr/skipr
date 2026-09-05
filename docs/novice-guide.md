# Novice guide — skipr

skipr is **available now**: a lean path of terminal + Claude Code + harness + short guides.
This page is for beginners. Follow the steps in order — you do not need to be a developer.

Spanish short mirror: [es/novice-guide.md](./es/novice-guide.md)

## Contents

1. [The novice path](#the-novice-path) (do this first — includes optional macOS installer)
2. [What to do next](#what-to-do-next)
3. [Harness deep-dive](#harness-setup-harness)
4. [Levels L0 → L2](#levels-l0--l2)
5. [This grows with you](#this-grows-with-you)

---

## The novice path

Goal: open a real project folder, give Claude Code short rails, and see a check that can say
*no*. That is your first win.

### 0. Optional: macOS install script (v0)

On a Mac, you can run the lean installer first. It checks Homebrew, **asks before
installing Ghostty** (or use `--with-ghostty`), copies `setup-harness` into
`~/.claude/skills/` (with a timestamped backup if replacing), and prints official
Claude Code install links if `claude` is missing.

**Always clone (or download a zip) first** so you can read the script:

```bash
git clone https://github.com/mgatorr/skipr.git
cd skipr
./scripts/install-macos.sh
```

Flags: `--dry-run`, `--with-ghostty`, `--with-zsh-extras`, `--force`, `--help` —
see [`scripts/README.md`](../scripts/README.md) (the curl|bash one-liner lives there
only, with a warning — not recommended as the novice path).

Spanish short guide: [es/novice-guide.md](./es/novice-guide.md).

If you skip the script, follow steps 1–4 manually below.

### 1. Install Claude Code CLI

You need the **CLI** (the `claude` command), not only the Claude desktop app.
Follow Anthropic’s current install guide for your OS, then confirm it works:

```bash
claude --version
```

Official install: [code.claude.com/docs/en/install](https://code.claude.com/docs/en/install)

If the command is “not found”, the CLI is not on your PATH yet — finish the install guide
before continuing.

### 2. Open a terminal you will actually use

On macOS we recommend **Ghostty** (clear, fast). The built-in Terminal.app or iTerm is
fine too. You are not hiding the terminal — you are learning one calm place to work.

- Ghostty: [ghostty.org](https://ghostty.org)
- Or pass `--with-ghostty` to `./scripts/install-macos.sh` (opt-in; default asks / skips)

### 3. Create or open your project folder

Work **inside the folder for this job** (a trip, a client delivery, a culling session) —
not a giant vault of prompts. Example:

```bash
mkdir -p ~/Projects/viaje-lisboa
cd ~/Projects/viaje-lisboa
```

Keep this terminal window in that folder for the rest of the steps.

### 4. Get the harness (setup-harness)

The harness is a short `CLAUDE.md` plus checks that can fail. The skill source lives in this
repo so you can read it on GitHub and install it into Claude Code’s skills folder.

Skill source: [`skills/setup-harness/`](../skills/setup-harness/)

**Clone or zip the repo first**, then copy (or use the macOS installer, which backs up
any existing skill):

```bash
# after: git clone https://github.com/mgatorr/skipr.git
cp -R /path/to/skipr/skills/setup-harness ~/.claude/skills/setup-harness
```

Claude Code CLI install (official): [code.claude.com/docs/en/install](https://code.claude.com/docs/en/install)

Then, in your project folder, start Claude Code and ask it to run the skill:

```bash
claude
# then, in the session:
# "Run setup-harness for this folder" / "Monta el harness en esta carpeta"
```

### 5. Run a checker (see “no” work)

After setup you should have a `checks/` directory. Run the primary script once:

```bash
./checks/naming.sh
# or brief-ready.sh / delivery.sh — whichever the harness installed
```

Green means the folder already passes. Red with a clear message is also a win — it proves
the rails can stop the agent. Read `checks/README.md` for how to break a check on purpose,
then ask Claude to fix it.

### 6. First win

You are done with “install” when all of this is true:

- `claude` runs in this folder
- There is a short `CLAUDE.md` (about ≤ 40 lines of body)
- At least one executable check under `checks/`
- You have run a check once and understood pass vs fail

---

## What to do next

1. Do real work in the folder with Claude Code — naming, brief, delivery — with the harness on.
2. When a rule keeps coming up, add one line to `CLAUDE.md` or one new checker. Keep both short.
3. Read [Levels (L0 → L2)](#levels-l0--l2) so you know what to ignore for now. Cursor, OpenCode, and Hermes stay optional — guides live in [`docs/l2/`](./l2/).
4. Optional: skim [`skills/setup-harness/SKILL.md`](../skills/setup-harness/SKILL.md) when you want the exact procedure the agent follows.

---

## Harness (setup-harness)

The harness is how skipr says *no*. A short `CLAUDE.md` in your project folder, plus scripts
under `checks/` that must be allowed to fail. **Fewer skills, more checks.**

### What setup-harness does

When you run the skill in a creative/project folder, it:

- Writes a short `CLAUDE.md` (body aimed at ≤ 40 lines)
- Creates `checks/` with at least one executable script that exits non-zero on failure
- Optionally adds at most two **local** skills under `.claude/skills/`
- Never copies Spec Kit, a Second Brain, or a pile of global skills into the project

Domains it knows (pick one): trip / client / culling / delivery — each maps to a default checker.

### How to run it (beginner)

1. Install the skill on your machine (`~/.claude/skills/setup-harness/`).
2. `cd` into the project folder — the harness is folder-scoped.
3. Ask Claude: `Run setup-harness for this folder` (or Spanish: `Monta el harness / arnés en esta carpeta`).
4. Smoke-test: `./checks/naming.sh` (pass or fail with a clear message — both are useful).

### Skill source

- [`SKILL.md`](../skills/setup-harness/SKILL.md) — full procedure the agent follows
- [`templates/`](../skills/setup-harness/templates/) — `CLAUDE.md`, checks, optional local skills

### After the harness is in

1. Work only in this folder with Claude Code.
2. Before calling something “done”, run the relevant `./checks/…` script.
3. If the model drifts, fix the check or tighten one line in `CLAUDE.md` — do not add 50 skills.
4. When L0/L1 feel solid, read [`docs/l2/`](./l2/) before adding an optional tool.

---

## Levels L0 → L2

skipr is leveled so you are not forced into every tool at once. Start at L0/L1. Add L2 only when
the basics feel boring in a good way.

### L0 — Terminal + folder

**Usable now.**

- A terminal you open on purpose (Ghostty or default)
- `cd` into the project folder before you chat with the agent
- No generic “second brain” vault as the workplace

If you can open the folder and run `claude` there, you are on the path.

### L1 — Claude Code + harness

**Usable now.** This is the core product surface today.

- Claude Code CLI in the project folder
- Short `CLAUDE.md` + `checks/` from setup-harness
- At most a couple of local skills — rails, not a hoard

Follow the novice path until you have a first win (a check that passes or fails clearly).

### L2 — Optional advanced tracks

**Optional growth — not required to start.** When L0 and L1 feel solid, you may add
**one** extra tool. Field notes (not a getting-started path):

- [L2 index](./l2/) — when to stay on L0/L1, when a track helps
- [Cursor](./l2/cursor.md) — IDE + PRs + cloud agents, *alongside* Claude Code
- [OpenCode](./l2/opencode.md) — second terminal agent / other model providers
- [Hermes](./l2/hermes.md) — occasional background agent; never the default path

- Complexity stays optional — you choose what joins the path
- L2 is optional growth — L0/L1 already are the product
- If the basics are not yet boring, stay on Claude Code + harness; that is enough to own the folder

---

## This grows with you

**L0 and L1 are usable now** — terminal + Claude Code + harness + these guides. That is
the product today.

**L2** field notes are in [`docs/l2/`](./l2/) (Cursor, OpenCode, Hermes). Complexity stays
optional; you level up when L0/L1 feel solid. This is an honest roadmap of growth — not an empty
“coming soon” stamp on the whole product.

---

*skipr is independent and not affiliated with Anthropic.*
