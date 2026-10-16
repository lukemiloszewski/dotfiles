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
| `platform/macos/` | `install.sh`, `brew.sh`. |
| `platform/windows/` | `bootstrap.ps1`, `profile.ps1`. |
| `scripts/` | `install.sh` (user tooling), `install-agents.sh`, `ssh.sh`. |
| `espanso/` | Text snippets, linked on macOS and Windows. |
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
