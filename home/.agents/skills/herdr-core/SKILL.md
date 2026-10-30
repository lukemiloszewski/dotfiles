---
name: herdr-core
description: "Use herdr-core (its CLI is hc) when $HC_TERMINAL_ID is set, or when a message arrives wrapped in <hc from=...> tags: to start sub-agents, talk to or coordinate other agents and panes, run background tasks or servers, run long-running commands, read or control terminals, or work on another machine; also to show or arrange things in the Herdr window or build Herdr mods and layouts. Inside Herdr, prefer it over your own sub-agent tool, shell '&', nohup or tmux."
---

<!-- From https://github.com/herdrdev/herdr-core/blob/master/skills/herdr-core/SKILL.md
     Local change: applies only inside Herdr ($HC_TERMINAL_ID set) or to an
     incoming <hc> message, instead of asking once per session elsewhere. -->

This skill is for herdr-core, whose command is `hc`. It is not `herdr`,
the older terminal multiplexer: that has its own `herdr` command and skill.
Use `hc` here, never `herdr`.

If `$HC_TERMINAL_ID` is set, you're running inside herdr-core: use hc.
If not, don't use hc unless the user asks for it; use your usual tools.

Before using hc, run `hc --skill` and follow it.
For the Herdr window (spaces, tabs, layouts, mods, what's shown),
run `herdr-app --skill`.
