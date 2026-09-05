#!/usr/bin/env bash
# skipr macOS installer (v0)
# Sets up the L0/L1 path: Homebrew guidance, Ghostty, optional lean zsh extras,
# Claude Code CLI guidance, and the setup-harness skill.
#
# Usage:
#   ./scripts/install-macos.sh [--help] [--dry-run] [--with-zsh-extras] [--force]
#
# Prefer cloning the repo and running locally. curl|bash also works (skill is
# fetched from GitHub). Script messages are English (product canon).

set -euo pipefail

SKIPR_REPO_URL="${SKIPR_REPO_URL:-https://github.com/mgatorr/skipr.git}"
SKIPR_REPO_RAW="${SKIPR_REPO_RAW:-https://raw.githubusercontent.com/mgatorr/skipr/main}"
CLAUDE_INSTALL_DOCS="https://code.claude.com/docs/en/install"
CLAUDE_NATIVE_INSTALL='curl -fsSL https://claude.ai/install.sh | bash'
CLAUDE_BREW_INSTALL='brew install --cask claude-code'
GHOSTTY_SITE="https://ghostty.org"
HOMEBREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
SKILL_DEST="${HOME}/.claude/skills/setup-harness"
ZSHRC_MARK_BEGIN="# >>> skipr zsh extras (managed by scripts/install-macos.sh) >>>"
ZSHRC_MARK_END="# <<< skipr zsh extras <<<"

DRY_RUN=0
WITH_ZSH_EXTRAS=0
FORCE=0
ASKED_ZSH=0

info()  { printf '==> %s\n' "$*"; }
ok()    { printf '    OK  %s\n' "$*"; }
warn()  { printf '    !!  %s\n' "$*"; }
step()  { printf '\n## %s\n' "$*"; }

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '    [dry-run] %s\n' "$*"
    return 0
  fi
  "$@"
}

usage() {
  cat <<'EOF'
skipr macOS installer (v0)

Sets up the lean L0/L1 path without rewriting your shell config by force.

Usage:
  ./scripts/install-macos.sh [options]

Options:
  --help              Show this help
  --dry-run           Print actions; change nothing
  --with-zsh-extras   Install lean zsh niceties (syntax-highlighting,
                      autosuggestions, fzf) and append a marked block to ~/.zshrc
  --force             Overwrite existing ~/.claude/skills/setup-harness

Safer for beginners (recommended):
  git clone https://github.com/mgatorr/skipr.git
  cd skipr
  ./scripts/install-macos.sh

Also works:
  curl -fsSL https://raw.githubusercontent.com/mgatorr/skipr/main/scripts/install-macos.sh | bash

Spanish guide: docs/es/novice-guide.md
EOF
}

is_macos() {
  [[ "$(uname -s)" == "Darwin" ]]
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

ghostty_installed() {
  command_exists ghostty && return 0
  [[ -d "/Applications/Ghostty.app" ]] && return 0
  [[ -d "${HOME}/Applications/Ghostty.app" ]] && return 0
  return 1
}

resolve_script_dir() {
  # When sourced from a real file (clone path), locate the repo.
  local src="${BASH_SOURCE[0]:-}"
  if [[ -n "$src" && "$src" != "-" && "$src" != "bash" && -f "$src" ]]; then
    cd "$(dirname "$src")" && pwd
    return 0
  fi
  return 1
}

find_local_skill() {
  local dir root
  if dir="$(resolve_script_dir 2>/dev/null)"; then
    root="$(cd "$dir/.." && pwd)"
    if [[ -f "$root/skills/setup-harness/SKILL.md" ]]; then
      printf '%s\n' "$root/skills/setup-harness"
      return 0
    fi
  fi
  # cwd fallback (run from repo root)
  if [[ -f "./skills/setup-harness/SKILL.md" ]]; then
    printf '%s\n' "$(pwd)/skills/setup-harness"
    return 0
  fi
  return 1
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --help|-h)
        usage
        exit 0
        ;;
      --dry-run)
        DRY_RUN=1
        shift
        ;;
      --with-zsh-extras)
        WITH_ZSH_EXTRAS=1
        shift
        ;;
      --force)
        FORCE=1
        shift
        ;;
      *)
        warn "Unknown option: $1"
        usage >&2
        exit 2
        ;;
    esac
  done
}

ensure_homebrew() {
  step "Homebrew"
  if command_exists brew; then
    ok "Homebrew found: $(command -v brew)"
    # Ensure brew is usable in this shell (Apple Silicon paths).
    if [[ -x /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
    elif [[ -x /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null || true
    fi
    return 0
  fi

  warn "Homebrew is not installed."
  cat <<EOF
    Install Homebrew (official), then re-run this script:

      /bin/bash -c "\$(curl -fsSL ${HOMEBREW_INSTALL_URL})"

    Docs: https://brew.sh
EOF
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '    [dry-run] would stop here until Homebrew is available (Ghostty via brew needs it)\n'
    return 0
  fi
  # Do not silently run the Homebrew installer (needs interactive password / confirmation).
  return 0
}

ensure_ghostty() {
  step "Ghostty (terminal)"
  if ghostty_installed; then
    ok "Ghostty already installed"
    return 0
  fi

  if ! command_exists brew; then
    warn "Cannot brew-install Ghostty without Homebrew."
    info "Install Ghostty from ${GHOSTTY_SITE} (or install Homebrew and re-run)."
    return 0
  fi

  info "Installing Ghostty via Homebrew cask…"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '    [dry-run] brew install --cask ghostty\n'
    return 0
  fi

  if brew install --cask ghostty; then
    ok "Ghostty installed"
  else
    warn "brew install --cask ghostty failed."
    info "Install manually from ${GHOSTTY_SITE}"
  fi
}

maybe_prompt_zsh_extras() {
  if [[ "$WITH_ZSH_EXTRAS" -eq 1 ]]; then
    return 0
  fi
  if [[ ! -t 0 ]]; then
    info "Skipping zsh extras (non-interactive; pass --with-zsh-extras to enable)."
    return 1
  fi
  ASKED_ZSH=1
  printf '\nInstall optional lean zsh niceties (syntax-highlighting, autosuggestions, fzf)? [y/N] '
  local ans
  read -r ans || ans=""
  case "$ans" in
    y|Y|yes|YES) WITH_ZSH_EXTRAS=1; return 0 ;;
    *) info "Skipping zsh extras."; return 1 ;;
  esac
}

zshrc_block() {
  local brew_prefix hl auto fzf_share
  brew_prefix="$(brew --prefix 2>/dev/null || true)"
  hl="${brew_prefix}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  auto="${brew_prefix}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  fzf_share="${brew_prefix}/opt/fzf/shell"

  cat <<EOF
${ZSHRC_MARK_BEGIN}
# Lean extras only — remove this block anytime.
if [ -f "${hl}" ]; then
  source "${hl}"
fi
if [ -f "${auto}" ]; then
  source "${auto}"
fi
if [ -f "${fzf_share}/key-bindings.zsh" ]; then
  source "${fzf_share}/key-bindings.zsh"
fi
if [ -f "${fzf_share}/completion.zsh" ]; then
  source "${fzf_share}/completion.zsh"
fi
${ZSHRC_MARK_END}
EOF
}

ensure_zsh_extras() {
  step "Optional zsh extras"
  if ! maybe_prompt_zsh_extras; then
    return 0
  fi

  if ! command_exists brew; then
    warn "Homebrew required for zsh extras. Skipping."
    return 0
  fi

  info "Installing zsh-syntax-highlighting, zsh-autosuggestions, fzf…"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '    [dry-run] brew install zsh-syntax-highlighting zsh-autosuggestions fzf\n'
    printf '    [dry-run] would append marked skipr block to ~/.zshrc (or print it)\n'
  else
    brew install zsh-syntax-highlighting zsh-autosuggestions fzf
  fi

  local zshrc="${HOME}/.zshrc"
  local block
  block="$(zshrc_block)"

  if [[ -f "$zshrc" ]] && grep -qF "$ZSHRC_MARK_BEGIN" "$zshrc" 2>/dev/null; then
    ok "~/.zshrc already has the skipr zsh extras block"
    return 0
  fi

  info "Appending a clearly marked skipr block to ~/.zshrc (does not rewrite the file)."
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '%s\n' "$block"
    return 0
  fi

  if [[ ! -f "$zshrc" ]]; then
    touch "$zshrc"
  fi
  {
    printf '\n'
    printf '%s\n' "$block"
  } >> "$zshrc"
  ok "Appended skipr block to ~/.zshrc — open a new shell or: source ~/.zshrc"

  cat <<'EOF'
    If you prefer not to modify ~/.zshrc automatically, remove the skipr block
    and add the same lines yourself (see scripts/README.md).
EOF
}

ensure_claude() {
  step "Claude Code CLI"
  if command_exists claude; then
    ok "claude found: $(command -v claude)"
    if claude --version >/dev/null 2>&1; then
      ok "version: $(claude --version 2>/dev/null | head -n1)"
    fi
    return 0
  fi

  warn "claude not found on PATH."
  cat <<EOF
    Install Claude Code CLI using Anthropic's official methods (do not invent URLs):

      Docs:  ${CLAUDE_INSTALL_DOCS}

      Native (recommended):
        ${CLAUDE_NATIVE_INSTALL}

      Homebrew:
        ${CLAUDE_BREW_INSTALL}

    Then confirm:
      claude --version
EOF
}

copy_skill_from_dir() {
  local src="$1"
  local dest="$SKILL_DEST"
  local dest_parent
  dest_parent="$(dirname "$dest")"

  info "Installing setup-harness → ${dest}"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '    [dry-run] mkdir -p %s\n' "$dest_parent"
    printf '    [dry-run] rm -rf %s && cp -R %s %s\n' "$dest" "$src" "$dest"
    return 0
  fi

  mkdir -p "$dest_parent"
  rm -rf "$dest"
  cp -R "$src" "$dest"
  ok "setup-harness installed at ${dest}"
}

fetch_skill_via_clone() {
  local tmp
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '    [dry-run] git clone --depth 1 %s <tmpdir> && copy skills/setup-harness\n' "$SKIPR_REPO_URL"
    return 0
  fi
  tmp="$(mktemp -d "${TMPDIR:-/tmp}/skipr-install.XXXXXX")"
  # shellcheck disable=SC2064
  trap "rm -rf '$tmp'" RETURN
  info "Cloning skipr (shallow) to fetch setup-harness…"
  git clone --depth 1 "$SKIPR_REPO_URL" "$tmp/skipr"
  if [[ ! -f "$tmp/skipr/skills/setup-harness/SKILL.md" ]]; then
    warn "Clone succeeded but skills/setup-harness is missing."
    return 1
  fi
  copy_skill_from_dir "$tmp/skipr/skills/setup-harness"
}

ensure_skill() {
  step "setup-harness skill"
  local src=""

  if [[ -d "$SKILL_DEST" && "$FORCE" -ne 1 ]]; then
    if [[ -t 0 ]]; then
      printf 'setup-harness already at %s — overwrite? [y/N] ' "$SKILL_DEST"
      local ans
      read -r ans || ans=""
      case "$ans" in
        y|Y|yes|YES) FORCE=1 ;;
        *)
          ok "Keeping existing skill (pass --force to overwrite)"
          return 0
          ;;
      esac
    else
      ok "Existing skill kept (non-interactive; pass --force to overwrite)"
      return 0
    fi
  fi

  if src="$(find_local_skill)"; then
    ok "Using local skill source: $src"
    copy_skill_from_dir "$src"
    return 0
  fi

  info "No local skills/setup-harness found (curl|bash or outside clone)."
  if command_exists git; then
    fetch_skill_via_clone
  else
    warn "git not found; cannot fetch skill automatically."
    cat <<EOF
    Clone the repo and re-run, or copy manually:

      git clone ${SKIPR_REPO_URL}
      cp -R skipr/skills/setup-harness ~/.claude/skills/setup-harness
EOF
    return 1
  fi
}

print_next_steps() {
  step "Next steps"
  cat <<'EOF'
  1. Create a real project folder (not a prompt vault):
       mkdir -p ~/Projects/my-project
       cd ~/Projects/my-project

  2. Start Claude Code:
       claude

  3. In the session, run the harness:
       "Run setup-harness for this folder"
       (Spanish: "Monta el harness en esta carpeta")

  4. Smoke-test a checker:
       ./checks/naming.sh

  Full guide: docs/novice-guide.md
  Spanish one-liner guide: docs/es/novice-guide.md
EOF
  if [[ "$DRY_RUN" -eq 1 ]]; then
    info "Dry-run complete — no changes were made."
  else
    info "Install script finished."
  fi
}

main() {
  parse_args "$@"

  info "skipr macOS installer (v0)"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    info "Dry-run mode: no changes will be made."
  fi
  info "Spanish guide: docs/es/novice-guide.md"

  if ! is_macos; then
    warn "This script targets macOS (Darwin). Detected: $(uname -s)."
    warn "Continue at your own risk — Ghostty/Homebrew steps may not apply."
  fi

  ensure_homebrew
  ensure_ghostty
  ensure_zsh_extras
  ensure_claude
  ensure_skill
  print_next_steps
}

main "$@"
