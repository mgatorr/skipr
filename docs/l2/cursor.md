# L2 — Cursor (alongside, not instead)

[Cursor](https://cursor.com) is an AI editor: a full IDE with inline edits, multi-file
agents, pull-request review, and optional cloud agents. In skipr it is an **L2 add-on**.
Claude Code in the project folder plus the harness stays the default path.

Index: [L2 tracks](./README.md) · Beginner path: [novice guide](../novice-guide.md)

## Who it’s for / when to add it

Add Cursor when L0/L1 already work and you keep hitting one of these:

- You need to **see and edit many files** in one place (diffs, rename, review)
- You work with **GitHub PRs** and want the change set visible, not only a chat log
- You want a **cloud agent** on the same repo for a longer job, while you stay on the
  folder rails

Do **not** add Cursor to “get started,” to hide the terminal, or to replace `claude`
in the project folder.

## Prerequisites

1. **L0** — a terminal you actually use; you `cd` into the job folder first
2. **L1** — Claude Code CLI (`claude --version`) in that folder
3. **Harness** — short `CLAUDE.md` + `checks/` from
   [`setup-harness`](../../skills/setup-harness/)
4. A first win: you have run a checker and understood pass vs fail

If any of that is missing, stop here. Finish the [novice guide](../novice-guide.md).

## How it fits the rails

- Open **the same project folder** you already use with Claude Code. Do not invent a
  parallel workspace or a prompt vault.
- The short `CLAUDE.md` is still the rule file. Cursor should follow it, not outgrow it.
- Before anyone (you, Cursor, a cloud agent) calls work “done”, run the same
  `./checks/…` scripts. A check that cannot fail is not a check.
- Cloud agents only help if they see the **same harness files in the repo**. If the
  agent cannot read `CLAUDE.md` and `checks/`, it is off the rails.

Working language for replies to the human still follows `Working language:` /
`SKIPR_LOCALE` / `LANG` — see [`docs/language.md`](../language.md). Product files stay
English.

## What not to do

- **Do not paste 400 Cursor rules.** A wall of `.cursorrules` / user rules is the same
  failure as 400 skills. If a rule keeps coming up, add **one line** to `CLAUDE.md` or
  **one checker**.
- **Do not cargo-cult a Second Brain.** Do not copy a Notion/Obsidian vault of prompts
  into Cursor “so the agent has context.” The workplace is the job folder.
- **Do not duplicate the harness** as a second constitution (`AGENTS.md`, long rules,
  spec kits) that fights `CLAUDE.md`.
- **Do not make Cursor the only agent.** Keep using Claude Code in the terminal for
  the everyday L1 loop. Cursor is extra surface, not a new religion.

## Keep it lean

- One project folder. One short `CLAUDE.md`. At most a couple of local skills.
- Install Cursor from the official site when you have a concrete gap — not because a
  comparison chart listed it.
- If you add editor rules, keep them *shorter* than `CLAUDE.md` and pointed at the
  same checks. Prefer no extra rules at all.
- When Cursor and Claude Code disagree, the **check** wins. Tighten the check, not
  the prompt pile.

Official product docs: [cursor.com/docs](https://cursor.com/docs) (install, models,
cloud agents). Those steps go stale; this page will not repeat them.

## See also

- [L2 index](./README.md) — when to stay on L0/L1
- [Novice guide](../novice-guide.md) — terminal + Claude Code + first win
- [`skills/setup-harness/`](../../skills/setup-harness/) — harness the agent must obey

## Trademark

Cursor is a trademark of its owner. skipr is independent and is **not affiliated**
with Cursor or Anthropic. “Claude” and “Claude Code” are trademarks of their
respective owner.
