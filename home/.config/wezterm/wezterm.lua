local wezterm = require 'wezterm'

local config = {
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

if wezterm.target_triple:find('windows') then
    config.default_prog = { 'powershell.exe' }
end

if wezterm.target_triple:find('darwin') then
    -- The NuPhy's macOS layers send Cmd from the physical Ctrl key (see
    -- keymap/README.md). Forward Cmd+<letter> as Ctrl+<letter> so the terminal
    -- behaves as it does on Windows: Ctrl+C interrupts, Ctrl+R searches history.
    for code = string.byte('a'), string.byte('z') do
        local letter = string.char(code)
        table.insert(config.keys, {
            key = letter,
            mods = 'SUPER',
            action = wezterm.action.SendKey { key = letter, mods = 'CTRL' },
        })
    end

    -- Word jumping, as Ctrl+arrows on Windows. Karabiner leaves WezTerm alone,
    -- so Cmd+arrows arrive here untouched.
    for _, arrow in ipairs { 'LeftArrow', 'RightArrow' } do
        table.insert(config.keys, { key = arrow, mods = 'SUPER', action = wezterm.action.SendKey { key = arrow, mods = 'CTRL' } })
        table.insert(config.keys, { key = arrow, mods = 'SUPER|SHIFT', action = wezterm.action.SendKey { key = arrow, mods = 'CTRL|SHIFT' } })
    end

    -- Same clipboard keys as Windows: Ctrl+V pastes, Ctrl+Shift+C copies.
    table.insert(config.keys, { key = 'v', mods = 'SUPER', action = wezterm.action.PasteFrom 'Clipboard' })
    table.insert(config.keys, { key = 'c', mods = 'SUPER|SHIFT', action = wezterm.action.CopyTo 'Clipboard' })

    -- Make Option behave as Alt so the Alt bindings above, and tmux's M-
    -- bindings, receive ESC-prefixed keys instead of composed characters.
    config.send_composed_key_when_left_alt_is_pressed = false
    config.send_composed_key_when_right_alt_is_pressed = false
end

return config
