# Language policy

## Canonical product language

**English** is the canonical language for skipr as a product and for this repository:

- README, docs (except secondary mirrors), skill instructions, commit messages, PR titles/bodies
- Code identifiers, comments in shared templates when they describe behavior for maintainers
- GitHub issues and public discussion (prefer English so the project stays readable worldwide)

Spanish (and other languages) may appear as **secondary mirrors** under `docs/es/` (and similar), linked from the English primary docs — never as a replacement for the English source of truth.

## Working conversation language (configurable)

When a human works with an agent (Claude Code, Cursor, etc.) on a **project folder**, the **spoken/written replies to that human** may use a different language than the product canon.

Convention (pick one; first match wins):

1. A line in the project `CLAUDE.md`:
   ```text
   Working language: es
   ```
   (or `en`, `fr`, … — BCP 47 / simple ISO 639-1 tags are enough)
2. Environment: `SKIPR_LOCALE` or `LANG` (e.g. `es`, `en_US.UTF-8` → treat as `en` for replies if only the language part matters)

Default if unset: **`en`**.

| Artifact | Language |
|---|---|
| Product docs / README / commits / PR bodies | English |
| Code & file names in harness templates | ASCII / English |
| Checker scripts’ user-facing fail messages | Match Working language when the harness was installed with that locale |
| Agent replies to the human | Working language (`Working language:` / `SKIPR_LOCALE` / `LANG`) |

## setup-harness

`skills/setup-harness` writes a short **Language** section into each project `CLAUDE.md`:

- English for code, paths, and commits
- Human-facing answers in `{{LANG}}` (default `en`; set to `es` when the human prefers Spanish)

See [README § Language](../README.md#language) and the root [CLAUDE.md](../CLAUDE.md).
