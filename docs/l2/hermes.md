# L2 — Hermes (optional, never the default path)

[Hermes Agent](https://hermes-agent.nousresearch.com/docs/) (Nous Research) is an
autonomous, multi-platform agent with a built-in **learning loop**: it can persist
memory, create skills from experience, and keep running away from your laptop
(CLI, desktop, or a gateway such as Telegram).

That is the opposite of skipr’s everyday shape. Hermes is an **L2 option** for a
narrow gap after L0/L1 are solid. It must not become how you start, and it must
not become the default place you work.

Index: [L2 tracks](./README.md) · Beginner path: [novice guide](../novice-guide.md)

## Who it’s for / when to add it

Consider Hermes only when all of this is true:

- Terminal + Claude Code + harness already feel boring in a good way
- You have a **concrete unattended job** (a report, a watch, a long background
  task) that the L1 loop does not cover
- You can name a stop condition — a check, a deadline, or “this folder is done”

Skip Hermes if you want a friendlier Claude Code, a Second Brain, or “the serious
setup.” Those motives add complexity. skipr exists to escape that.

## Prerequisites

1. **L0** — you open a terminal and work in the project folder
2. **L1** — Claude Code CLI + short `CLAUDE.md` + `checks/` from
   [`setup-harness`](../../skills/setup-harness/)
3. A first win on the [novice guide](../novice-guide.md)
4. You understand that Hermes will try to **grow memory and skills**. You are
   willing to prune

If you cannot yet let a checker say *no* to Claude Code, do not give an autonomous
agent more rope.

## How it relates (without becoming the path)

| skipr default (L0/L1) | Hermes (L2) |
|---|---|
| You are in the folder | It can live on a VPS, gateway, or desktop |
| Short rails, few skills | Learning loop *creates* skills and memory |
| Claude Code is the everyday agent | Occasional background helper |

Use Hermes **beside** the folder, not as a new home. The job still lives in the
same directory. The harness still decides what “done” means.

Official install and setup: [Hermes docs](https://hermes-agent.nousresearch.com/docs/)
(install script, `hermes setup`, providers). Follow upstream for those steps; they
change. Then:

1. Point it at **one** project folder, not a vault of every prompt you ever wrote
2. Tell it the harness exists: read `CLAUDE.md`, run `./checks/…` before claiming done
3. Turn off or prune skill auto-creation until you have a reason to keep a skill
4. Do not route your daily naming / brief / delivery loop through Hermes. That loop
   stays Claude Code in the terminal

## What not to do

- **Do not start here.** Hermes is not L0
- **Do not let the learning loop become a Second Brain.** Persistent memory plus
  auto-skills is how folders turn into prompt museums
- **Do not install the skill marketplace** “so it is complete”
- **Do not** run unattended work without a check that can fail and a way you will
  notice
- **Do not** treat gateway chat (Telegram, etc.) as a replacement for opening the
  folder

## Keep it lean

- One optional agent, used rarely. If you open Hermes more than Claude Code, you
  have inverted the levels — go back to L1
- Cap skills the same way setup-harness does: at most a couple, local, folder-scoped
- Provider keys via env / the tool’s auth — never committed
- If Hermes writes extra markdown constitutions, delete or shrink them. `CLAUDE.md`
  stays short

## See also

- [L2 index](./README.md) — when to stay on L0/L1
- [Novice guide](../novice-guide.md)
- [`skills/setup-harness/`](../../skills/setup-harness/)

## Trademark

Hermes and related names are trademarks of Nous Research and/or their respective
owners. skipr is independent and is **not affiliated** with Nous Research or
Anthropic. “Claude” and “Claude Code” are trademarks of their respective owner.
