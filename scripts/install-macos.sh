#!/usr/bin/env bash
# skipr macOS installer (v0)
# Sets up the L0/L1 path: Homebrew guidance, optional Ghostty, optional lean zsh extras,
# Claude Code CLI guidance, the setup-harness and fdd skills, and the optional
# session meter (fdd setup --user).
#
# Usage:
#   ./scripts/install-macos.sh [--help] [--dry-run] [--with-ghostty] [--with-zsh-extras]
#                          [--with-session-meter] [--force]
#
# Primary path: git clone the repo, then run this script locally.
# curl|bash is secondary (see scripts/README.md). Script messages are English (product canon).

set -euo pipefail

SKIPR_REPO_URL="${SKIPR_REPO_URL:-https://github.com/mgatorr/skipr.git}"
CLAUDE_INSTALL_DOCS="https://code.claude.com/docs/en/install"
CLAUDE_NATIVE_INSTALL='curl -fsSL https://claude.ai/install.sh | bash'
CLAUDE_BREW_INSTALL='brew install --cask claude-code'
GHOSTTY_SITE="https://ghostty.org"
HOMEBREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
SKILL_DEST="${HOME}/.claude/skills/setup-harness"
FDD_DEST="${HOME}/.claude/skills/fdd"
BACKUP_ROOT="${HOME}/.claude/skills-backup"
# Staging dir created beside the skill. Cleared on failure so a signal cannot
# leave .<name>.staging.* under ~/.claude/skills.
SKIPR_STAGING=""
# Set while a skill is moved aside. A signal before the swap lands moves the
# backup back, so the skill is never left only in skills-backup.
SKIPR_SWAP_DEST=""
SKIPR_SWAP_BACKUP=""
ZSHRC_MARK_BEGIN="# >>> skipr zsh extras (managed by scripts/install-macos.sh) >>>"
ZSHRC_MARK_END="# <<< skipr zsh extras <<<"

DRY_RUN=0
WITH_GHOSTTY=0
WITH_ZSH_EXTRAS=0
WITH_SESSION_METER=0
FORCE=0
# Set by the skills step: the local source tree, and whether fdd is (or on
# --dry-run would be) copied from it.
SKIPR_SRC_ROOT=""
FDD_WILL_REPLACE=0

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

macOS-only. On Linux or Windows this script exits non-zero (including --dry-run).
See scripts/README.md and examples/photo-trip (novice-guide step 0).

Sets up the lean L0/L1 path without rewriting your shell config by force.

Usage:
  ./scripts/install-macos.sh [options]

Options:
  --help              Show this help
  --dry-run           Print actions; change nothing
  --with-ghostty      Install Ghostty via Homebrew cask (otherwise ask / skip)
  --with-zsh-extras   Install lean zsh niceties (syntax-highlighting,
                      autosuggestions, fzf) and append a marked block to ~/.zshrc
  --with-session-meter
                      Turn on the session meter (fdd setup --user) without
                      asking; otherwise ask [Y/n], or skip when non-interactive
  --force             Overwrite existing setup-harness and fdd skills.
                      Each previous copy is moved to
                      ~/.claude/skills-backup/<name>.<unique>

Primary path (recommended):
  git clone https://github.com/mgatorr/skipr.git
  cd skipr
  ./scripts/install-macos.sh
EOF
}

is_macos() {
  [[ "$(uname -s)" == "Darwin" ]]
}

# macOS-only: refuse on Linux/Windows (and --dry-run). --help still works
# because parse_args exits first.
refuse_unless_macos() {
  if is_macos; then
    return 0
  fi
  cat <<EOF >&2
This script is macOS-only (detected: $(uname -s)).

On Linux or Windows: clone this repo, copy skills/setup-harness, and use your
own terminal. See scripts/README.md and step 0 in examples/photo-trip.
EOF
  exit 1
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

find_repo_root() {
  local dir root
  if dir="$(resolve_script_dir 2>/dev/null)"; then
    root="$(cd "$dir/.." && pwd)"
    if [[ -f "$root/skills/setup-harness/SKILL.md" ]]; then
      printf '%s\n' "$root"
      return 0
    fi
  fi
  # cwd fallback (run from repo root)
  if [[ -f "./skills/setup-harness/SKILL.md" ]]; then
    pwd
    return 0
  fi
  return 1
}

# True for a real path or a symlink, including a dangling symlink.
skill_exists() {
  [[ -e "$1" || -L "$1" ]]
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
      --with-ghostty)
        WITH_GHOSTTY=1
        shift
        ;;
      --with-zsh-extras)
        WITH_ZSH_EXTRAS=1
        shift
        ;;
      --with-session-meter)
        WITH_SESSION_METER=1
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

maybe_prompt_ghostty() {
  if [[ "$WITH_GHOSTTY" -eq 1 ]]; then
    return 0
  fi
  if [[ ! -t 0 ]]; then
    info "Skipping Ghostty install (non-interactive; pass --with-ghostty to enable)."
    info "Install manually from ${GHOSTTY_SITE} if you want it."
    return 1
  fi
  printf '\nInstall Ghostty terminal via Homebrew cask? [y/N] '
  local ans
  read -r ans || ans=""
  case "$ans" in
    y|Y|yes|YES) WITH_GHOSTTY=1; return 0 ;;
    *)
      info "Skipping Ghostty. Use Terminal.app / iTerm, or install from ${GHOSTTY_SITE}."
      return 1
      ;;
  esac
}

ensure_ghostty() {
  step "Ghostty (terminal, optional)"
  if ghostty_installed; then
    ok "Ghostty already installed"
    return 0
  fi

  if ! maybe_prompt_ghostty; then
    return 0
  fi

  if ! command_exists brew; then
    warn "Cannot brew-install Ghostty without Homebrew."
    info "Install Ghostty from ${GHOSTTY_SITE} (or install Homebrew and re-run with --with-ghostty)."
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

# 0 = install or replace. 1 = keep the skill that is already there.
should_replace_skill() {
  local dest="$1" label="$2" ans
  if ! skill_exists "$dest"; then
    return 0
  fi
  if [[ "$FORCE" -eq 1 ]]; then
    return 0
  fi
  if [[ -t 0 ]]; then
    printf '%s already at %s — overwrite (with backup)? [y/N] ' "$label" "$dest"
    read -r ans || ans=""
    case "$ans" in
      y|Y|yes|YES) return 0 ;;
    esac
  fi
  ok "Keeping existing ${label} (pass --force to overwrite with backup)"
  return 1
}

drop_staging_dir() {
  if [[ -n "${SKIPR_STAGING}" && -d "${SKIPR_STAGING}" ]]; then
    rm -rf "${SKIPR_STAGING}"
  fi
  SKIPR_STAGING=""
}

restore_swap_backup() {
  local dest="${SKIPR_SWAP_DEST}" backup="${SKIPR_SWAP_BACKUP}"
  SKIPR_SWAP_DEST=""
  SKIPR_SWAP_BACKUP=""
  [[ -n "$dest" && -n "$backup" ]] || return 0
  if ! skill_exists "$dest" && skill_exists "$backup"; then
    if mv "$backup" "$dest"; then
      warn "Interrupted; restored the previous skill at ${dest}"
    else
      warn "Interrupted; previous skill left at ${backup}"
    fi
  fi
}

# Copy into a temp dir beside dest, then swap. A failure removes the temp dir
# and, if the previous skill was already moved aside, moves that backup back.
# Callers use `|| return`, which turns off set -e for this function, so each
# mkdir / mktemp / rm is checked on its own.
install_one_skill() {
  local label="$1" src="$2" dest="$3"
  local parent staging backup=""
  if [[ ! -d "$src" ]]; then
    warn "No ${label} source at ${src}"
    return 1
  fi
  if ! should_replace_skill "$dest" "$label"; then
    return 0
  fi
  if [[ "$label" == fdd ]]; then
    FDD_WILL_REPLACE=1
  fi
  parent="$(dirname "$dest")"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '    [dry-run] mkdir -p %s\n' "$parent"
    printf '    [dry-run] copy %s to a temp dir next to %s, then swap\n' "$src" "$dest"
    if skill_exists "$dest"; then
      printf '    [dry-run] mv %s %s/%s.<unique>\n' "$dest" "$BACKUP_ROOT" "$label"
    fi
    return 0
  fi

  mkdir -p "$parent" || return 1
  staging="$(mktemp -d "${parent}/.${label}.staging.XXXXXX")" || return 1
  case "$staging" in
    "$parent"/."$label".staging.*) ;;
    *)
      warn "Could not create a temp dir next to ${dest}"
      return 1
      ;;
  esac
  if [[ ! -d "$staging" ]]; then
    warn "Could not create a temp dir next to ${dest}"
    return 1
  fi
  SKIPR_STAGING="$staging"
  # mktemp -d makes it 0700; the installed skill dir should be 0755.
  if ! chmod 755 "$staging"; then
    drop_staging_dir
    warn "Could not set permissions on the temp dir for ${label}"
    return 1
  fi
  if ! cp -R "${src}/." "${staging}/"; then
    drop_staging_dir
    warn "Copy of ${label} failed; left the existing skill unchanged"
    return 1
  fi
  if skill_exists "$dest"; then
    if ! mkdir -p "$BACKUP_ROOT"; then
      drop_staging_dir
      warn "Could not create ${BACKUP_ROOT}"
      return 1
    fi
    backup="$(mktemp "${BACKUP_ROOT}/${label}.XXXXXX")" || {
      drop_staging_dir
      warn "Could not create a backup path for ${label}"
      return 1
    }
    case "$backup" in
      "$BACKUP_ROOT"/"$label".*) ;;
      *)
        drop_staging_dir
        warn "Could not create a backup path for ${label}"
        return 1
        ;;
    esac
    if [[ ! -e "$backup" ]]; then
      drop_staging_dir
      warn "Could not create a backup path for ${label}"
      return 1
    fi
    if ! rm -f "$backup"; then
      drop_staging_dir
      warn "Could not prepare backup path ${backup}"
      return 1
    fi
    SKIPR_SWAP_DEST="$dest"
    SKIPR_SWAP_BACKUP="$backup"
    if ! mv "$dest" "$backup"; then
      SKIPR_SWAP_DEST=""
      SKIPR_SWAP_BACKUP=""
      drop_staging_dir
      warn "Could not move ${dest} aside (backup path ${backup})"
      return 1
    fi
    info "Backup at ${backup}"
  fi
  if ! mv "$staging" "$dest"; then
    SKIPR_SWAP_DEST=""
    SKIPR_SWAP_BACKUP=""
    drop_staging_dir
    if [[ -n "$backup" ]] && skill_exists "$backup"; then
      if mv "$backup" "$dest"; then
        warn "Swap of ${label} failed; restored the previous skill (backup was ${backup})"
      else
        warn "Swap of ${label} failed; backup left at ${backup}"
      fi
    else
      warn "Swap of ${label} failed"
    fi
    return 1
  fi
  SKIPR_STAGING=""
  SKIPR_SWAP_DEST=""
  SKIPR_SWAP_BACKUP=""
  ok "${label} installed at ${dest}"
}

install_skills_from_root() {
  local root="$1"
  install_one_skill setup-harness "$root/skills/setup-harness" "$SKILL_DEST" || return 1
  if [[ -f "$root/skills/fdd/SKILL.md" ]]; then
    install_one_skill fdd "$root/skills/fdd" "$FDD_DEST" || return 1
  else
    warn "skills/fdd not in this tree; skipped."
  fi
}

# The curl|bash clone, removed on return and by the INT, TERM and EXIT traps.
CLONE_TMP=""
drop_clone_tmp() {
  if [[ -n "$CLONE_TMP" && -d "$CLONE_TMP" ]]; then rm -rf "$CLONE_TMP"; fi
  CLONE_TMP=""
}

fetch_skill_via_clone() {
  local tmp status
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '    [dry-run] git clone --depth 1 %s <tmpdir> && copy skills\n' "$SKIPR_REPO_URL"
    return 0
  fi
  if ! tmp="$(mktemp -d "${TMPDIR:-/tmp}/skipr-install.XXXXXX")" || [[ -z "$tmp" || ! -d "$tmp" ]]; then
    warn "Could not create a temporary directory."
    return 1
  fi
  CLONE_TMP="$tmp"
  info "Cloning skipr (shallow) to fetch skills…"
  if ! git clone --depth 1 "$SKIPR_REPO_URL" "$tmp/skipr"; then
    warn "Clone failed."
    drop_clone_tmp
    return 1
  fi
  if [[ ! -f "$tmp/skipr/skills/setup-harness/SKILL.md" ]]; then
    warn "Clone succeeded but skills/setup-harness is missing."
    drop_clone_tmp
    return 1
  fi
  status=0
  install_skills_from_root "$tmp/skipr" || status=$?
  drop_clone_tmp
  return "$status"
}

ensure_skill() {
  step "skills"
  local root=""

  if root="$(find_repo_root)"; then
    ok "Using local skill source: $root/skills"
    SKIPR_SRC_ROOT="$root"
    install_skills_from_root "$root" || return 1
    return 0
  fi

  # No local checkout. Skip the clone when both skills are already kept.
  if [[ "$FORCE" -ne 1 ]] && skill_exists "$SKILL_DEST" && skill_exists "$FDD_DEST"; then
    ok "Existing skills kept (non-interactive; pass --force to overwrite with backup)"
    return 0
  fi

  info "No local skills found (curl|bash or outside clone)."
  if command_exists git; then
    fetch_skill_via_clone || return 1
  else
    warn "git not found; cannot fetch skill automatically."
    cat <<EOF
    Clone ${SKIPR_REPO_URL} to ~/skipr (or unzip it there) and re-run,
    or copy manually:

      (
        cd ~/skipr &&
        mkdir -p ~/.claude/skills &&
        if [ -e ~/.claude/skills/setup-harness ]; then
          mkdir -p ~/.claude/skills-backup &&
          bak="\$(mktemp ~/.claude/skills-backup/setup-harness.XXXXXX)" &&
          rm "\$bak" &&
          mv ~/.claude/skills/setup-harness "\$bak"
        fi &&
        cp -R skills/setup-harness ~/.claude/skills/setup-harness &&
        if [ -e ~/.claude/skills/fdd ]; then
          mkdir -p ~/.claude/skills-backup &&
          bak="\$(mktemp ~/.claude/skills-backup/fdd.XXXXXX)" &&
          rm "\$bak" &&
          mv ~/.claude/skills/fdd "\$bak"
        fi &&
        cp -R skills/fdd ~/.claude/skills/fdd
      )
EOF
    return 1
  fi
}

# The session meter: fdd setup --user puts the context meter in Claude Code's
# status line, backup first. Default yes when asked; skipped when nothing can
# ask, unless --with-session-meter.
ensure_session_meter() {
  step "Session meter (context in tokens)"
  local fdd="" plan out rc=0 ans
  local nl=$'\n'
  if [[ "$DRY_RUN" -eq 1 && "$FDD_WILL_REPLACE" -eq 1 ]]; then
    # Nothing was copied on --dry-run: plan with the source tree's fdd.
    if [[ -n "$SKIPR_SRC_ROOT" ]]; then
      fdd="$SKIPR_SRC_ROOT/skills/fdd/bin/fdd"
    fi
  elif skill_exists "$FDD_DEST"; then
    fdd="$FDD_DEST/bin/fdd"
  fi
  if [[ -z "$fdd" ]]; then
    if [[ "$DRY_RUN" -eq 1 ]]; then
      printf '    [dry-run] would offer fdd setup --user once the fdd skill is copied\n'
    else
      warn "No fdd skill at ${FDD_DEST}; the session meter is skipped."
    fi
    return 0
  fi
  # A kept fdd skill from before fdd setup cannot turn the meter on.
  if [[ ! -x "$fdd" ]] || ! "$fdd" setup --help >/dev/null 2>&1; then
    warn "your fdd skill is older; re-run with --force to update it"
    info "The session meter is skipped."
    return 0
  fi
  if [[ "$WITH_SESSION_METER" -ne 1 && ! -t 0 ]]; then
    info "Skipping the session meter (non-interactive; pass --with-session-meter to turn it on)."
    return 0
  fi

  info "It shows the context in tokens and warns before every message gets expensive."
  if ! plan="$("$fdd" setup --user --dry-run 2>&1)"; then
    printf '%s\n' "$plan" | sed 's/^/    /'
    warn "fdd setup cannot merge ~/.claude/settings.json; the session meter is skipped."
    return 0
  fi
  printf '%s\n' "$plan" | sed 's/^/    /'
  # No "+" line: the meter is already on, or your own status line is kept.
  if [[ "$plan" != *"${nl}  + "* ]]; then
    return 0
  fi

  if [[ "$WITH_SESSION_METER" -ne 1 ]]; then
    printf '\nTurn on the session meter? [Y/n] '
    read -r ans || ans=""
    case "$ans" in
      ""|y|Y|yes|Yes|YES) ;;
      *)
        info "Skipping the session meter. Later: ~/.claude/skills/fdd/bin/fdd setup --user"
        return 0
        ;;
    esac
  fi
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '    [dry-run] %s setup --user --yes\n' "$FDD_DEST/bin/fdd"
    return 0
  fi
  out="$("$fdd" setup --user --yes 2>&1)" || rc=$?
  printf '%s\n' "$out" | sed 's/^/    /'
  if [[ "$rc" -ne 0 ]]; then
    warn "The session meter was not turned on (see above)."
    return 0
  fi
  ok "Session meter on for new Claude Code sessions"
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

  4. Smoke-test a checker:
       ./checks/naming.sh

  5. One task per session: when the meter turns red, or the topic changes, type /clear.
     Open Claude Code sessions keep their old settings; start new ones.

  Full guide: docs/novice-guide.md
EOF
  if [[ "$DRY_RUN" -eq 1 ]]; then
    info "Dry-run complete — no changes were made."
  else
    info "Install script finished."
  fi
}

main() {
  trap 'drop_staging_dir; restore_swap_backup; drop_clone_tmp; exit 130' INT
  trap 'drop_staging_dir; restore_swap_backup; drop_clone_tmp; exit 143' TERM
  trap 'status=$?; if [[ "$status" -ne 0 ]]; then drop_staging_dir; fi; drop_clone_tmp; exit "$status"' EXIT
  parse_args "$@"
  refuse_unless_macos

  info "skipr macOS installer (v0)"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    info "Dry-run mode: no changes will be made."
  fi
  ensure_homebrew
  ensure_ghostty
  ensure_zsh_extras
  ensure_claude
  ensure_skill
  ensure_session_meter
  print_next_steps
}

main "$@"
