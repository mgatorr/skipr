# scripts/

Helper scripts for skipr. Product messages are English; Spanish guides live under `docs/es/`.

## install-macos.sh (v0)

Beginner-friendly macOS installer for the L0/L1 path:

- Checks Homebrew (prints official install instructions if missing — does not force-run it)
- **Ghostty is opt-in** (`--with-ghostty` or interactive `y/N`; default skip in non-interactive runs)
- Optionally adds lean zsh niceties (`zsh-syntax-highlighting`, `zsh-autosuggestions`, `fzf`) behind `--with-zsh-extras` or a yes/no prompt — appends a **marked** block to `~/.zshrc`, never rewrites the whole file
- Detects Claude Code CLI (`claude`); if missing, prints Anthropic’s official install docs/commands
- Copies `skills/setup-harness` → `~/.claude/skills/setup-harness` (`--force` overwrites **after a timestamped backup**)

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
| `--force` | Overwrite existing `~/.claude/skills/setup-harness` (after timestamped backup) |

### curl | bash (secondary — use with care)

> **Warning:** piping remote scripts to `bash` means you run code you have not inspected locally. Prefer the clone path above.

```bash
curl -fsSL https://raw.githubusercontent.com/mgatorr/skipr/main/scripts/install-macos.sh | bash
```

When there is no local checkout, the script shallow-clones the public repo to copy the skill, then cleans up the temp dir.

### After install

```bash
mkdir -p ~/Projects/my-project
cd ~/Projects/my-project
claude
# "Run setup-harness for this folder"
```

See [docs/novice-guide.md](../docs/novice-guide.md) · Spanish: [docs/es/novice-guide.md](../docs/es/novice-guide.md).
