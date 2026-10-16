#!/usr/bin/env bash
# bootstrap.sh — link dotfiles into $HOME (macOS and Linux).
#
# Idempotent: safe to re-run after adding a dotfile. Tooling installation
# lives in platform/ and scripts/install.sh; this script only arranges files
# that already exist. Windows uses platform/windows/bootstrap.ps1.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info() { printf '\033[0;32m[dotfiles]\033[0m %s\n' "$*"; }
warn() { printf '\033[0;33m[dotfiles]\033[0m %s\n' "$*" >&2; }

# Link every file under $1 to the same relative path under $2.
#
# Files, never directories. Linking a whole directory hands it to whatever
# tool writes there, which is how ~/.config once dumped runtime state into
# this repo. Walking the tree also means adding a dotfile is enough for it to
# be deployed; there is no list to maintain.
link_tree() {
  local src_root="$1" dst_root="$2" src rel dst linked=0
  [[ -d "${src_root}" ]] || return 0
  while IFS= read -r src; do
    rel="${src#"${src_root}/"}"
    dst="${dst_root}/${rel}"
    mkdir -p "$(dirname "${dst}")"
    if [[ -e "${dst}" && ! -L "${dst}" ]]; then
      warn "  ${rel} exists as a real file — moved to ${rel}.bak"
      mv "${dst}" "${dst}.bak"
    fi
    ln -sfn "${src}" "${dst}"
    linked=$((linked + 1))
  done < <(find "${src_root}" -type f)
  info "Linked ${linked} files into ${dst_root}"
}

# Copy files from seed/ only when absent. For config that a tool rewrites
# itself (a symlink would write straight back into this repo) or that holds
# per-machine state.
seed_home() {
  local src rel dst
  [[ -d "${REPO_DIR}/seed" ]] || return 0
  while IFS= read -r src; do
    rel="${src#"${REPO_DIR}/seed/"}"
    dst="${HOME}/${rel}"
    if [[ -e "${dst}" ]]; then
      continue
    fi
    mkdir -p "$(dirname "${dst}")"
    cp "${src}" "${dst}"
    info "Seeded ~/${rel}"
  done < <(find "${REPO_DIR}/seed" -type f)
}

# home/.gitconfig holds no identity; it includes this file. Set GIT_NAME,
# GIT_EMAIL and GITHUB_USER to run non-interactively, or answer the prompts.
write_git_identity() {
  local dst="${HOME}/.gitconfig.local" name email user
  if [[ -f "${dst}" ]]; then
    info "Git identity present"
    return
  fi
  name="${GIT_NAME:-}"
  email="${GIT_EMAIL:-}"
  user="${GITHUB_USER:-}"
  if [[ -z "${name}" || -z "${email}" ]]; then
    if [[ -t 0 ]]; then
      read -r -p "Git name: " name
      read -r -p "Git email: " email
      read -r -p "GitHub user (optional): " user
    else
      warn "No ~/.gitconfig.local and no GIT_NAME/GIT_EMAIL set; commits will have no identity."
      return
    fi
  fi
  info "Writing ${dst}"
  {
    printf '[user]\n\tname = %s\n\temail = %s\n' "${name}" "${email}"
    if [[ -n "${user}" ]]; then
      printf '\n[github]\n\tuser = %s\n' "${user}"
    fi
  } > "${dst}"
}

check_tooling() {
  local missing=() tool
  for tool in tmux git zsh delta starship uv; do
    command -v "${tool}" >/dev/null 2>&1 || missing+=("${tool}")
  done
  if (( ${#missing[@]} > 0 )); then
    warn "Not installed: ${missing[*]}"
    warn "Run platform/<os>/ package scripts, then scripts/install.sh."
  else
    info "All expected tooling present"
  fi
}

main() {
  mkdir -p "${HOME}/code" "${HOME}/.local/bin"
  link_tree "${REPO_DIR}/home" "${HOME}"
  link_tree "${REPO_DIR}/bin" "${HOME}/.local/bin"
  if [[ "$(uname -s)" == "Darwin" ]]; then
    link_tree "${REPO_DIR}/espanso" "${HOME}/Library/Application Support/espanso"
  fi
  seed_home
  write_git_identity
  check_tooling
  info "Done."
}

main "$@"
