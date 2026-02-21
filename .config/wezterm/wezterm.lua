local wezterm = require 'wezterm'

return {
    default_prog = { 'powershell.exe' },

    allow_win32_input_mode = true,

    keys = {
        { key = 'h', mods = 'ALT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
        { key = 'v', mods = 'ALT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
        { key = 'w', mods = 'ALT', action = wezterm.action.CloseCurrentPane { confirm = false } },
        { key = 'LeftArrow',  mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Left' },
        { key = 'RightArrow', mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Right' },
        { key = 'UpArrow',    mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Up' },
        { key = 'DownArrow',  mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Down' },
        { key = 'LeftArrow',  mods = 'ALT|SHIFT', action = wezterm.action.ActivateTabRelative(-1) },
        { key = 'RightArrow', mods = 'ALT|SHIFT', action = wezterm.action.ActivateTabRelative(1) },
        { key = 'v', mods = 'CTRL', action = wezterm.action.PasteFrom 'Clipboard' },
        { key = 'LeftArrow',  mods = 'CTRL|SHIFT', action = wezterm.action.SendKey { key = 'LeftArrow',  mods = 'CTRL|SHIFT' } },
        { key = 'RightArrow', mods = 'CTRL|SHIFT', action = wezterm.action.SendKey { key = 'RightArrow', mods = 'CTRL|SHIFT' } },
        { key = 'UpArrow',    mods = 'CTRL|SHIFT', action = wezterm.action.SendKey { key = 'UpArrow',    mods = 'CTRL|SHIFT' } },
        { key = 'DownArrow',  mods = 'CTRL|SHIFT', action = wezterm.action.SendKey { key = 'DownArrow',  mods = 'CTRL|SHIFT' } },
    },
}
