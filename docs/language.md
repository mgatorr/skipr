# Language policy

## Canonical product language

**English** is the language of skipr and of this repository:

- README, docs, skill instructions, commit messages, PR titles and bodies
- Code identifiers, file names, and comments in shared templates
- GitHub issues and public discussion

There are no translated mirrors in this repo. Product files stay English.

## Working conversation language (configurable)

When a human works with an agent on a **project folder**, replies to that human may use another language. The files in the repo stay English.

Convention (pick one; first match wins):

1. A line in the project `CLAUDE.md`:
   ```text
   Working language: es
   ```
   (or `en`, `fr`, … — BCP 47 / simple ISO 639-1 tags are enough)
2. Environment: `SKIPR_LOCALE` or `LANG` (for example `es`, or `en_US.UTF-8` — use the language part)

Default if unset: **`en`**.

| Artifact | Language |
|---|---|
| Product docs / README / commits / PR bodies | English |
| Code and file names in harness templates | English |
| Checker scripts' user-facing messages | English |
| Agent replies to the human | Working language (`Working language:` / `SKIPR_LOCALE` / `LANG`) |

## setup-harness

`skills/setup-harness` writes a short **Language** section into each project `CLAUDE.md`:

- English for code, paths, commits, and file names
- Human-facing answers in `{{LANG}}` (default `en`)

Checker messages stay English either way.

See [README § Language](../README.md#language) and the root [CLAUDE.md](../CLAUDE.md).
