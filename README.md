# Dotfiles

Personal configuration for macOS, Windows and Linux. Development happens on a
remote Linux host; macOS and Windows are the client side (terminal, prompt,
snippets).

## Layout

| Path | Contents |
|---|---|
| `home/` | Mirror of `$HOME`. Every file is symlinked to the same path. |
| `bin/` | Tools linked into `~/.local/bin`, currently `lmux`. |
| `seed/` | Files copied into `$HOME` once, for config a tool rewrites itself. |
| `platform/linux/` | `dnf.sh`, `apt.sh` (root), `install-tmux.sh` (tmux 3.x from source). |
| `platform/macos/` | `install.sh`, `brew.sh`, `vscode/keybindings.json` (linked into VS Code's user folder). |
| `platform/windows/` | `bootstrap.ps1`, `profile.ps1`. |
| `scripts/` | `install.sh` (user tooling), `install-agents.sh`, `ssh.sh`. |
| `espanso/` | Text snippets, linked on macOS and Windows. |
| `keyboards/` | VIA definition and saved keymap for the NuPhy Air75 V2. Not linked. |
| `keymap/` | Shortcut inventory and the Windows-parity model for macOS. |
| `plugins/` | Claude plugin for `lmux`. |

## Install

Linux (remote host):

```shell
git clone https://github.com/lukemiloszewski/dotfiles.git "${HOME}/code/dotfiles"

sudo bash "${HOME}/code/dotfiles/platform/linux/dnf.sh"   # or apt.sh
bash "${HOME}/code/dotfiles/scripts/install.sh"           # tooling, then links
bash "${HOME}/code/dotfiles/scripts/install-agents.sh"    # optional
```

macOS:

```shell
git clone https://github.com/lukemiloszewski/dotfiles.git "${HOME}/code/dotfiles"
zsh "${HOME}/code/dotfiles/platform/macos/install.sh"
```

Windows (PowerShell):

```powershell
git clone https://github.com/lukemiloszewski/dotfiles.git "$HOME\code\dotfiles"
& "$HOME\code\dotfiles\platform\windows\bootstrap.ps1"
```

`bootstrap.sh` is safe to re-run. Adding a file under `home/` is enough to
deploy it. Files are linked, never directories, so tools write to `$HOME`
rather than into this repo. An existing real file is moved to `<name>.bak`.

## Local overrides

Nothing person-, machine- or employer-specific is tracked. Each hook is sourced
if it exists and is ignored by git:

| File | For |
|---|---|
| `~/.gitconfig.local` | Git identity, credential helper, per-machine settings. Created by `bootstrap.sh` from `GIT_NAME`, `GIT_EMAIL`, `GITHUB_USER` or prompts. |
| `~/.zshrc.local` | Exports, aliases and `PATH`. Loaded before tools such as nvm initialise, so environment variables set there apply to them. |
| `~/.tmux.conf.local` | Extra tmux bindings. |

## Secrets

API keys and tokens live in 1Password. `home/.config/secrets/.env.op` lists every one as a
reference (`NAME='{{ op://<vault>/<item>/<field> }}'`) and holds no values.

| Path | Contents |
|---|---|
| `~/.config/secrets/.env.op` | The references. Linked. |
| `~/.config/secrets/.env` | The values, written by `secrets-refresh` (`.aliases`) with mode 600. Untracked, excluded from Time Machine, and blocked for agents by the Claude guards. |

`secrets-refresh` asks for Touch ID once, then every new shell loads
`~/.config/secrets/.env` from `.zshrc`, so agents and unattended runs need no 1Password
prompt. Run it again after adding or rotating a secret. Each repo commits a
`.env.example` naming the variables it reads, with empty values.

## Claude Code

User-level config, so it applies in every repo and every git worktree (project
`.claude/` files are gitignored and absent from a fresh worktree unless the repo
lists them in `.worktreeinclude`).

| Path | Contents |
|---|---|
| `home/.claude/scripts/statusline.sh` | Status line: directory, branch, model, lines changed, cost. Linked. |
| `home/.claude/hooks/` | `git-guard.sh` and `bash-guard.sh` block destructive git and shell commands; `file-guard.sh` blocks writes to system, credential and shell config paths. Linked. If `file-guard.sh` proves too restrictive, drop its entry from the seed. |
| `seed/.claude/settings.json` | Wires the status line and the three guards, plus mode, effort, theme and public plugin marketplaces. Copied once, because Claude Code rewrites `~/.claude/settings.json`. |

An existing `~/.claude/settings.json` is never overwritten; merge by hand. Anything
employer-specific (private marketplaces, plugins) belongs in the work overlay, not here.

## lmux

Lets an agent read, type into, and spawn tmux panes, so several agents can work
side by side and message each other. It is a standalone script, so a shell or
CI job can call it with no agent involved.

```shell
lmux list                      # all panes with labels
lmux spawn api -h "make run-api"
lmux read api 40
lmux message reviewer "take a look at src/app"
```

Interacting with a pane requires reading it first; the mark clears after each
action, so every interaction is read → act. Run `lmux doctor` if a target
cannot be reached, usually a stale `$TMUX` after a terminal restart.

Vendored from [ShawnPana/smux](https://github.com/ShawnPana/smux) at `f8f591b`,
where it is called `tmux-bridge`, with fixes to the guard-file location, label
resolution and `doctor` output, plus `spawn` and `kill`.

The agent skill that drives it ships as a plugin:

```shell
/plugin marketplace add lukemiloszewski/dotfiles
/plugin install lmux@dotfiles
```

The plugin gives an agent the instructions, not the tool; `bootstrap.sh` puts
`lmux` on `PATH`.

## roborev

`scripts/install-agents.sh` installs it. Its config lives in `seed/.roborev/`
and is copied once, because roborev rewrites the file itself and a symlink would
write straight back into this repo. The file can take an API key, so keep it out
of version control: edit `~/.roborev/config.toml`, not the seed.
