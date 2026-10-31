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
    # A link left behind by an earlier layout whose target is gone.
    [[ -L "${dst}" ]] && rm "${dst}"
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

# Skills live once, in ~/.agents/skills (home/.agents/skills here), which pi
# and other agents read. Claude Code reads only ~/.claude/skills, so give it a
# link per skill. A real folder of the same name there is left alone.
link_agent_skills() {
  local src_root="${HOME}/.agents/skills" dst_root="${HOME}/.claude/skills" src dst linked=0
  [[ -d "${src_root}" ]] || return 0
  mkdir -p "${dst_root}"
  for src in "${src_root}"/*/; do
    src="${src%/}"
    dst="${dst_root}/$(basename "${src}")"
    if [[ -e "${dst}" && ! -L "${dst}" ]]; then
      warn "  ~/.claude/skills/$(basename "${src}") is a real folder — not linked"
      continue
    fi
    ln -sfn "${src}" "${dst}"
    linked=$((linked + 1))
  done
  info "Linked ${linked} skills into ${dst_root}"
}

# MCP servers are declared once, in ~/.agents/mcp.json (home/.agents/mcp.json
# here, in the common `mcpServers` format, with ${HOME} for the home folder).
# Each agent that keeps servers in its own config gets every one registered
# there, replacing an older registration of the same name. Agents without MCP
# use the skills, which also describe a command line fallback.
register_agent_mcp() {
  local config="${HOME}/.agents/mcp.json" name server word registered=0
  local -a argv
  [[ -f "${config}" ]] || return 0
  if ! command -v jq >/dev/null 2>&1; then
    warn "jq not installed — MCP servers in ~/.agents/mcp.json not registered"
    return 0
  fi
  while IFS= read -r name; do
    server="$(jq -c --arg name "${name}" --arg home "${HOME}" \
      '.mcpServers[$name] | walk(if type == "string" then gsub("\\$\\{HOME\\}"; $home) else . end)' \
      "${config}")"
    if command -v claude >/dev/null 2>&1; then
      claude mcp remove --scope user "${name}" >/dev/null 2>&1 || true
      claude mcp add-json --scope user "${name}" "${server}" >/dev/null
    fi
    if command -v codex >/dev/null 2>&1; then
      argv=()
      while IFS= read -r word; do argv+=("${word}"); done \
        < <(jq -r '[.command] + (.args // []) | .[]' <<< "${server}")
      codex mcp remove "${name}" >/dev/null 2>&1 || true
      codex mcp add "${name}" -- "${argv[@]}" >/dev/null
    fi
    registered=$((registered + 1))
  done < <(jq -r '.mcpServers | keys[]' "${config}")
  info "Registered ${registered} MCP servers from ~/.agents/mcp.json"
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
    link_tree "${REPO_DIR}/platform/macos/vscode" "${HOME}/Library/Application Support/Code/User"
  fi
  link_agent_skills
  register_agent_mcp
  seed_home
  write_git_identity
  check_tooling
  info "Done."
}

main "$@"
