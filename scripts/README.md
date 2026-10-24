# scripts/

Helper scripts for skipr. Product messages are English.

`./scripts/check-docs.sh` exits non-zero when a tracked file contains a term from the banned list (`DOCS_BANNED` or a local `.docs-banned`), a capped doc is too long, or a relative Markdown link is broken. With no list it warns and skips only the term scan; in CI (`CI` or `GITHUB_ACTIONS` set to `true`) it exits 1 and prints `DOCS_BANNED secret not set`.

**Linux/Windows ≠ this installer.** `install-macos.sh` is macOS-only and **exits
non-zero** on other OSes (including `--dry-run`). Clone (or unzip) this repo, copy
`skills/setup-harness` and `skills/fdd`, and use the terminal you already have. First win:
[`examples/photo-trip`](../examples/photo-trip/) (novice-guide step 0). See also
[docs/novice-guide.md](../docs/novice-guide.md).

## install-macos.sh (v0)

Beginner-friendly macOS installer for the L0/L1 path:

- Checks Homebrew (prints official install instructions if missing — does not force-run it)
- **Ghostty is opt-in** (`--with-ghostty` or interactive `y/N`; default skip in non-interactive runs)
- Optionally adds lean zsh niceties (`zsh-syntax-highlighting`, `zsh-autosuggestions`, `fzf`) behind `--with-zsh-extras` or a yes/no prompt — appends a **marked** block to `~/.zshrc`, never rewrites the whole file
- Detects Claude Code CLI (`claude`); if missing, prints Anthropic’s official install docs/commands
- Copies `skills/setup-harness` and `skills/fdd` into `~/.claude/skills/` (`--force` moves the previous folder to `~/.claude/skills-backup/<name>.<unique>`, outside `~/.claude/skills`)

### Primary path (clone — recommended)

```bash
git clone https://github.com/mgatorr/skipr.git
cd skipr
./scripts/install-macos.sh
```

Or download a zip from GitHub, unzip, then run the same script from the extracted folder.

### Flags

| Flag | Meaning |
|---|---|
| `--help` | Usage |
| `--dry-run` | Print actions; change nothing |
| `--with-ghostty` | Install Ghostty via Homebrew cask (otherwise ask / skip) |
| `--with-zsh-extras` | Install lean zsh packages + append marked `~/.zshrc` block |
| `--force` | Overwrite existing `~/.claude/skills/setup-harness` and `~/.claude/skills/fdd` (backup under `~/.claude/skills-backup/<name>.<unique>`) |

### curl | bash (secondary — use with care)

> **Warning:** piping remote scripts to `bash` means you run code you have not inspected locally. Prefer the clone path above.

```bash
curl -fsSL https://raw.githubusercontent.com/mgatorr/skipr/main/scripts/install-macos.sh | bash
```

When there is no local checkout, the script shallow-clones the public repo to copy the skill, then cleans up the temp dir.

### After install

Open your project folder and start Claude Code. In the session, ask:
*Run setup-harness for this folder*.

```bash
mkdir -p ~/Projects/my-project
cd ~/Projects/my-project
claude
```

See [docs/novice-guide.md](../docs/novice-guide.md).
