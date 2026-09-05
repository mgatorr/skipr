# L2 — OpenCode (second terminal agent)

[OpenCode](https://opencode.ai) is an open-source AI coding agent. It runs in the
terminal (TUI), and also as a desktop app or IDE extension. It can talk to many
model providers.

In skipr, OpenCode is an **optional L2 track** — a second agent you may add after
Claude Code + harness already work. It is not the default path and not a reason to
skip L0/L1.

Index: [L2 tracks](./README.md) · Beginner path: [novice guide](../novice-guide.md)

## Who it’s for / when to add it

Add OpenCode when L0/L1 feel solid and you have a *specific* reason, for example:

- You want a **terminal agent that is not Claude Code**, in the same folder
- You need a **non-Anthropic model** (or to switch providers) without leaving the
  terminal habit you already have
- You already trust the harness and want a second pair of hands on the same rails

Do **not** start skipr with OpenCode. Do not install it to collect agents. Claude
Code remains the L1 default.

## Prerequisites

1. **L0** — terminal + `cd` into the project folder
2. **L1** — Claude Code CLI works in that folder (`claude --version`)
3. **Harness** — short `CLAUDE.md` + `checks/` from
   [`setup-harness`](../../skills/setup-harness/)
4. You have run a checker and understood pass vs fail

If that loop is not yet boring, stay on the [novice guide](../novice-guide.md).

## What it is relative to Claude Code

| | Claude Code (L1 default) | OpenCode (L2 optional) |
|---|---|---|
| Role in skipr | Everyday agent | Extra terminal agent |
| Form | CLI in the project folder | TUI / desktop / IDE extension |
| Models | Anthropic (Claude) | Many providers; you configure keys |
| Rails | `CLAUDE.md` + `checks/` | **Same files** — do not grow a second constitution |

OpenCode is not “Claude Code but open.” It is another agent. The skipr bet is still
**folder + harness + a CLI you can read**, not a new stack.

## Lean setup pointers

Official install and auth: [opencode.ai/docs](https://opencode.ai/docs). Typical
paths (verify upstream; they change):

```bash
# examples only — prefer the current official docs
brew install anomalyco/tap/opencode
# or: curl -fsSL https://opencode.ai/install | bash
```

Then:

1. `cd` into the **same** project folder you already use with Claude Code
2. Connect **one** provider (`/connect` in the TUI, or the current docs). Do not
   configure five “just in case”
3. Run `opencode` there — not from a generic vault
4. Treat `/init` with care. OpenCode may want to write an `AGENTS.md`. If you
   already have a short `CLAUDE.md`, **do not** let `/init` become a second,
   longer constitution. Point the agent at the existing harness; keep any extra
   file shorter than `CLAUDE.md` or skip it
5. Before “done”: `./checks/…` — same scripts as L1

Provider keys stay in the environment or the tool’s own auth store. Never commit
secrets. See the constitution’s security rule and [`docs/language.md`](../language.md).

## What not to do

- Do not make OpenCode the getting-started agent
- Do not dump a plugin / skill marketplace into the project
- Do not copy a Second Brain so “every agent has context”
- Do not run overnight loops with no check that can fail

## Keep it lean

- One folder, one harness, one extra agent — not a fleet
- Prefer the TUI in the project directory; desktop/IDE ports are optional later
- If OpenCode and Claude Code disagree, the **check** wins
- Uninstall it if you are not using it. Optional means you can put it down

## See also

- [L2 index](./README.md)
- [Novice guide](../novice-guide.md)
- [`skills/setup-harness/`](../../skills/setup-harness/)

## Trademark

OpenCode is a trademark of its owner. skipr is independent and is **not affiliated**
with Anomaly / OpenCode or Anthropic. “Claude” and “Claude Code” are trademarks of
their respective owner.
