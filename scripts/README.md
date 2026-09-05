# scripts/

Helper scripts for skipr. Product messages are English; Spanish guides live under `docs/es/`.

## install-macos.sh (v0)

Beginner-friendly macOS installer for the L0/L1 path:

- Checks Homebrew (prints official install instructions if missing — does not force-run it)
- Installs Ghostty via `brew install --cask ghostty` when needed (or points to [ghostty.org](https://ghostty.org))
- Optionally adds lean zsh niceties (`zsh-syntax-highlighting`, `zsh-autosuggestions`, `fzf`) behind `--with-zsh-extras` or a yes/no prompt — appends a **marked** block to `~/.zshrc`, never rewrites the whole file
- Detects Claude Code CLI (`claude`); if missing, prints Anthropic’s official install docs/commands
- Copies `skills/setup-harness` → `~/.claude/skills/setup-harness` (`--force` to overwrite)

### Recommended (clone)

```bash
git clone https://github.com/mgatorr/skipr.git
cd skipr
./scripts/install-macos.sh
```

### Flags

| Flag | Meaning |
|---|---|
| `--help` | Usage |
| `--dry-run` | Print actions; change nothing |
| `--with-zsh-extras` | Install lean zsh packages + append marked `~/.zshrc` block |
| `--force` | Overwrite existing `~/.claude/skills/setup-harness` |

### curl | bash (works, clone preferred)

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
