local wezterm = require 'wezterm'

-- The Alt bindings are shared with .tmux.conf. Inside tmux, pass the key
-- through so tmux splits and switches; otherwise WezTerm does it itself.
local function tmux_or(key, mods, action)
    return {
        key = key,
        mods = mods,
        action = wezterm.action_callback(function(window, pane)
            local process = pane:get_foreground_process_name() or ''
            if process:find('tmux') then
                window:perform_action(wezterm.action.SendKey { key = key, mods = mods }, pane)
            else
                window:perform_action(action, pane)
            end
        end),
    }
end

local config = {
    allow_win32_input_mode = true,

    keys = {
        tmux_or('h', 'ALT', wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' }),
        tmux_or('v', 'ALT', wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' }),
        tmux_or('w', 'ALT', wezterm.action.CloseCurrentPane { confirm = false }),
        tmux_or('t', 'ALT', wezterm.action.SpawnTab 'CurrentPaneDomain'),
        tmux_or('LeftArrow',  'ALT', wezterm.action.ActivatePaneDirection 'Left'),
        tmux_or('RightArrow', 'ALT', wezterm.action.ActivatePaneDirection 'Right'),
        tmux_or('UpArrow',    'ALT', wezterm.action.ActivatePaneDirection 'Up'),
        tmux_or('DownArrow',  'ALT', wezterm.action.ActivatePaneDirection 'Down'),
        tmux_or('LeftArrow',  'ALT|SHIFT', wezterm.action.ActivateTabRelative(-1)),
        tmux_or('RightArrow', 'ALT|SHIFT', wezterm.action.ActivateTabRelative(1)),
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
