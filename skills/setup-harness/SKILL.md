---
name: setup-harness
description: Use when scaffolding a minimal AI harness for a photo (or other non-software) project folder — "setup harness", "monta el arnés", checkers for a trip/client/culling folder, CLAUDE.md corto + checks that can fail, without Spec Kit or a Second Brain. Also when helping photographers move from the Claude app to the terminal (Ghostty/Orca) with a lean setup.
---

# Setup Harness

Install a **minimal harness** in the current project folder so Claude Code
(or any coding agent) has short rails and a check that can say **no**.

This is **not** Spec Kit, not a Second Brain, and not a pile of skills.
Target user: photographers / creators who already try Claude in the app
and need a folder-scoped setup they can trust.

**Core principle:** fewer skills, more checks. If the check cannot fail,
it is not a check.

## Language

- **Canonical product / repo language:** English (this skill file; commits when contributing upstream).
- **Project `CLAUDE.md` must include a short Language section:** English for code/commits/paths; replies to the human in `{{LANG}}` (default `en`, can be `es`).
- Also write the line `Working language: {{LANG}}` so agents can detect locale (`SKIPR_LOCALE` / `LANG` are alternatives; see `docs/language.md` in the skipr repo).
- Checker fail messages: prefer the same `{{LANG}}` the harness was installed with.

## When to use

- "Monta el harness / arnés en esta carpeta"
- New trip, client job, culling session, delivery pack as a folder
- Teaching someone to leave the Claude desktop app and work in the
  terminal inside the project directory
- Replacing a bloated skill dump with one lean setup

## When NOT to use

- Software products with Spec Kit / constitution / wave fencing
  (Spottura, Fly, etc.) — use the product's own tooling
- "Install every useful skill I saw on Twitter"
- Overnight autonomous loops without a measurable stop condition

## Prerequisites (tell the human if missing)

1. **Claude Code CLI** installed (`claude` in PATH), not only the app.
2. Terminal they actually use (Ghostty, iTerm, Terminal.app; Orca or
   similar is fine as a wrapper).
3. They open the session **in this folder** (`cd` here first). Working
   from a generic vault and hoping the agent finds the photos is the
   failure mode this skill exists to prevent.

## Domains

Ask once (or infer from the folder name) and pick **one**:

| Domain | Local skill to install | Default checker |
|---|---|---|
| `viaje` / trip | `naming-viaje` | `checks/naming.sh` |
| `cliente` / client | `brief-cliente` | `checks/brief-ready.sh` |
| `culling` | (none beyond CLAUDE.md) | `checks/naming.sh` |
| `delivery` | `delivery-checklist` | `checks/delivery.sh` |

Install **at most two** local skills. Never copy Spec Kit. Never copy a
Second Brain. Never install global skills into the project.

## Procedure

Work in the **current working directory** (the photo project). Do not
jump to `~/.claude` except to read this skill's templates.

### 1. Confirm folder

- If the folder has an existing software `CLAUDE.md` that is clearly a
  product constitution (Spec Kit, iOS, Workers), **stop** and ask: this
  skill is for photo/creative folders, not product repos.
- If a harness already exists (`checks/` + short CLAUDE.md mentioning
  harness), offer to refresh checks only; do not duplicate skills.

### 2. Ask domain if unknown

One question. Default to `viaje` if the folder looks like a trip name.

### 3. Write `CLAUDE.md`

Copy from this skill's `templates/CLAUDE.md`, then substitute:

- `{{PROJECT_NAME}}` — folder basename or human title
- `{{DOMAIN}}` — viaje | cliente | culling | delivery
- `{{LANG}}` — working conversation language (default `en`; use `es` for Spanish). Code/paths/commits stay English ASCII

Hard rules for the file you write:

- **≤ 40 lines** of body (frontmatter optional; prefer none)
- No Spec Kit, no constitution versioning, no wave/ola language
- Must include: Language section (`Working language: {{LANG}}`); work only in this folder;
  do not invent EXIF/GPS/dates; ask if the brief is missing; run `./checks/…` before claiming done

### 4. Create `checks/`

Copy the matching scripts from `templates/checks/`:

- Always copy `README.md`
- Domain table above decides which `.sh` files
- `chmod +x` every `.sh`

Each script must:

- Exit `0` on success, non-zero on failure
- Print a clear message of what failed (in `{{LANG}}`)
- Be safe to run twice
- Never delete user photos (read-only checks only)

### 5. Optional local skills (max 2)

Create `.claude/skills/<name>/SKILL.md` by copying from
`templates/skills/<name>/` for the chosen domain only.

Do **not** install skills globally. Do **not** add Spec Kit skills.

### 6. Smoke test

Run the primary checker once. Expect either:

- green (folder already clean), or
- red with an actionable message (good — show the human that failure works)

Then tell them how to break it on purpose (README section).

### 7. Closing message (always print)

Print in the human working language (`{{LANG}}`, default English):

```text
Harness ready in: <pwd>

1. Open the terminal in THIS folder (Ghostty / Orca / yours).
2. Start Claude Code here:  claude
3. Before claiming done:  ./checks/<script>.sh
4. To prove the harness works: break a checker on purpose
   (see checks/README.md) and ask the agent to fix it.

Not a Second Brain. Do not copy 50 skills. Extra rules go in
CLAUDE.md (keep it short) or a new checker under checks/.
```

If `{{LANG}}` is `es`, use the Spanish equivalent of the same four steps.

## Templates location

All files to copy live next to this `SKILL.md`:

```
templates/CLAUDE.md
templates/checks/README.md
templates/checks/naming.sh
templates/checks/brief-ready.sh
templates/checks/delivery.sh
templates/skills/brief-cliente/SKILL.md
templates/skills/naming-viaje/SKILL.md
templates/skills/delivery-checklist/SKILL.md
```

Resolve paths relative to this skill directory (where Claude loaded
`setup-harness` from), typically `~/.claude/skills/setup-harness/`.

## Quality bar

- After setup, `wc -l CLAUDE.md` body ≤ 40 lines
- `find .claude/skills -type d -mindepth 1 -maxdepth 1 | wc -l` ≤ 2
- At least one executable check under `checks/`
- No `speckit-*` directories created
