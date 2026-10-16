---
name: lmux
description: Control tmux panes and communicate between AI agents on this machine. Use whenever the user mentions tmux panes or windows, cross-pane communication, sending work to or reading from another agent, spawning panes for parallel work, or driving a process running in another pane. Provides the lmux CLI plus raw tmux commands.
---

# lmux

Pane control and cross-pane agent communication. Prefer `lmux` for
anything involving another pane; drop to raw tmux only for layout work it does
not cover.

**Requires `tmux` and `lmux` on `PATH`.** `lmux` is a standalone
script in the [dotfiles](https://github.com/lukemiloszewski/dotfiles) repo
at `bin/lmux`, put on `PATH` by its `bootstrap.sh`. If it is missing,
say so rather than falling back to raw `tmux send-keys` — the read-guard below
is the point of the tool, and bypassing it is how an agent types into a pane
blind.

## Read-act cycle

Every interaction with a pane is **read → act**. The CLI enforces it: `type`,
`keys` and `message` refuse to run unless you have read the pane first, and the
mark is cleared after each act, so a second act needs a second read.

```sh
lmux read api 20          # see what is there
lmux type api "make test" # stage the text
lmux read api 5           # confirm it landed
lmux keys api Enter       # commit to it
```

This exists so an agent cannot blind-type into a pane whose state it has not
checked — the pane may be mid-prompt, in a pager, or running something.

## Do not poll

When you message another agent, its reply arrives **in your own pane** as a
`[lmux from:...]` line. Do not sleep, loop, or re-read the target pane
waiting for it. Send, then carry on with other work.

Read the target pane only: before acting on it (required), to confirm text
landed before pressing Enter, or when it is a plain shell rather than an agent.

## Commands

| Command | Purpose |
|---|---|
| `lmux list` | All panes: target, process, label, cwd |
| `lmux spawn <label> [-h\|-v] [cmd]` | Split the current pane, label the new one |
| `lmux kill <target>` | Kill a pane |
| `lmux read <target> [lines]` | Read the last N lines (default 50) |
| `lmux type <target> <text>` | Type text, no Enter |
| `lmux keys <target> <key>...` | Send keys (`Enter`, `Escape`, `C-c`) |
| `lmux message <target> <text>` | Type text prefixed with sender and reply target |
| `lmux name <target> <label>` | Label a pane (shows in the border) |
| `lmux resolve <label>` | Print the pane id for a label |
| `lmux id` | This pane's id |
| `lmux doctor` | Diagnose connectivity |

Targets may be a **label**, a pane id (`%31`), or a native tmux target. Labels
resolve first, so `ai_api.main` works despite the dot.

## Spawning a workspace

`spawn` splits the *current* pane and labels the result, so build a layout by
spawning from where you want the split to happen:

```sh
lmux spawn api -h "make run-api"   # right half
lmux spawn tests -v                # bottom-right, empty shell
```

A command passed to `spawn` is sent to the new pane's shell rather than
replacing it, so the pane survives the command exiting and stays usable.

Labels must be unique; reusing one is an error rather than a silent retarget.

## Talking to another agent

```sh
lmux read reviewer 20
lmux message reviewer "Review src/app/rules.py — focus on the validation logic"
lmux read reviewer 5
lmux keys reviewer Enter
```

`message` prepends your label, pane id and location so the other agent knows
who to reply to. Override the reply instruction with `LMUX_REPLY_HINT`.

Note that `message` types into a live agent's prompt. Read first, and check the
pane is at a prompt rather than mid-task.

## Raw tmux

For anything the bridge does not cover:

```sh
tmux list-panes -a -F '#{pane_id} #{@name} #{pane_current_command}'
tmux select-layout tiled              # retile the window
tmux resize-pane -t api -x 100        # resize
tmux new-window -c "$PWD"             # new window
tmux capture-pane -t api -p -S -      # full scrollback
tmux kill-session -t scratch
```

Pane labels are the `@name` pane option, so `tmux set-option -p -t %31 @name x`
and `lmux name %31 x` are equivalent.

## Troubleshooting

`lmux doctor` reports the detected socket, guard directory, and whether
this pane is visible to the server.

The usual failure is a stale `$TMUX` after a terminal restart: the socket in
the environment no longer exists. The bridge falls back to scanning for the
socket that owns `$TMUX_PANE`; if that fails, set `LMUX_SOCKET`
explicitly.
