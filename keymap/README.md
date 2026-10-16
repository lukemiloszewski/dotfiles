# Keymap

Windows is the reference. The NuPhy Air75 V2 sends the same keys on both
systems, and macOS is remapped so the same physical key presses do the same
thing.

## Model

| Physical key | Windows layer | macOS layer | Why |
|---|---|---|---|
| Left Ctrl | Ctrl | Cmd | App shortcuts (`Ctrl+C`, `Ctrl+T`) land on macOS's `Cmd` equivalents |
| Win | Win | Ctrl | Keeps a real Ctrl on macOS for the terminal |
| Alt | Alt | Option | Alt-bindings in WezTerm and tmux; AltTab uses Option+Tab |

The firmware does the swap (VIA, USB only). Anything the swap does not cover is
handled per app, in code:

| Layer | Config | Handles |
|---|---|---|
| Keyboard | `keyboards/nuphy-air75-v2/nuphy_air75_v2.layout.json` | The table above, plus F1–F12 on both base layers |
| Terminal | `home/.config/wezterm/wezterm.lua` | `Cmd+<letter>` → `Ctrl+<letter>`, Option as Alt |
| macOS leftovers | `seed/.config/karabiner/assets/complex_modifications/windows-parity.json` | Rows marked Karabiner |
| VS Code | `platform/macos/vscode/keybindings.json` | Custom Ctrl bindings and terminal interrupt |

Status: ✅ works once the swap is in place · 🔧 needs a rule · ❓ unverified,
check on the machine · ➖ Windows-only.

Every 🔧 row now has a rule. Rows are confirmed on a real machine once they
pass the EventViewer checks in step 5.

## Set up on macOS

1. **Keyboard.** On USB, open [usevia.app](https://usevia.app) in Chrome or
   Edge. If the board isn't detected, load
   `keyboards/nuphy-air75-v2/nuphy-air75-v2-via3.json` on the Design tab
   (enable **Show Design tab** in Settings). Under **Save + Load**, save the
   current layout as a backup, then **Load Saved Layout** with
   `keyboards/nuphy-air75-v2/nuphy_air75_v2.layout.json`.
2. **Apps.** Install WezTerm and Karabiner-Elements (both in
   `platform/macos/brew.sh`):

   ```shell
   brew install --cask wezterm karabiner-elements
   ```

   Run this in a real terminal: the Karabiner installer uses `sudo` and fails
   without a password prompt (e.g. from an agent session). Open Karabiner
   (`open -a Karabiner-Elements`), approve the driver extension and Input
   Monitoring in System Settings, and restart if macOS asks. In the Keyboard
   Setup Assistant choose **ANSI**.
3. **Link the config.** Run `bootstrap.sh` (or `platform/macos/install.sh` on a
   fresh machine). It links `~/.config/wezterm/wezterm.lua` and copies the rule
   file to `~/.config/karabiner/assets/complex_modifications/windows-parity.json`.
   The rule file lives in `seed/`, not `home/`, because Karabiner does not list
   symlinked rule files; seeds are copied once and never overwritten.
4. **Enable the rules.** In Karabiner, open **Complex Modifications**, click
   **Add predefined rule**, and enable all four rules under **Windows parity**.
   Enabling copies a rule into `~/.config/karabiner/karabiner.json`, which
   Karabiner rewrites itself. After editing the repo file, copy it over the
   seeded one, then remove and re-enable the rules:

   ```shell
   cp seed/.config/karabiner/assets/complex_modifications/windows-parity.json \
     ~/.config/karabiner/assets/complex_modifications/
   ```
5. **Test.** In Karabiner's **EventViewer**, press the physical keys and check
   the output: `Ctrl+Left` gives `Option+Left`, `Home` gives `Cmd+Left`,
   `Ctrl+Home` gives `Cmd+Up`, `Ctrl+Backspace` gives `Option+Delete`,
   `Ctrl+Y` gives `Cmd+Shift+Z`, `` Ctrl+` `` in VS Code gives `` Ctrl+` ``,
   `Ctrl+Tab` in Chrome gives `Ctrl+Tab`, and `Alt+F4` gives `Cmd+Q`.
   If `Home` jumps by word, the rule order is wrong: the word-jump manipulators
   must come before the `Home`/`End` ones, because `Home` outputs `Cmd+Left`.

Karabiner doesn't chain manipulators: a rule's output is not remapped again,
so `Alt+Left` (back in Chrome) and `Ctrl+Left` (which outputs `Option+Left`)
don't collide.

## Text editing (any app)

| Action | Windows | macOS | Status |
|---|---|---|---|
| Copy / cut / paste | Ctrl+C / X / V | Cmd+C / X / V | ✅ |
| Undo | Ctrl+Z | Cmd+Z | ✅ |
| Redo | Ctrl+Y | Cmd+Shift+Z | ✅ (Karabiner) |
| Select all / save / find | Ctrl+A / S / F | Cmd+A / S / F | ✅ |
| Word left / right | Ctrl+←/→ | Option+←/→ | ✅ (Karabiner) |
| Select word | Ctrl+Shift+←/→ | Option+Shift+←/→ | ✅ (Karabiner) |
| Delete previous / next word | Ctrl+Backspace / Delete | Option+Delete / Fn+Option+Delete | ✅ (Karabiner, also in WezTerm) |
| Line start / end | Home / End | Cmd+←/→ | ✅ (Karabiner) |
| Document start / end | Ctrl+Home / End | Cmd+↑/↓ | ✅ (Karabiner) |

## Chrome

| Action | Windows | macOS | Status |
|---|---|---|---|
| New tab / close / reopen | Ctrl+T / W / Shift+T | Cmd+T / W / Shift+T | ✅ |
| Address bar | Ctrl+L | Cmd+L | ✅ |
| Switch to tab 1–8 | Ctrl+1–8 | Cmd+1–8 | ✅ |
| Next / previous tab | Ctrl+Tab / Ctrl+Shift+Tab | Ctrl+Tab / Ctrl+Shift+Tab | ✅ (Karabiner: Cmd+Tab becomes Ctrl+Tab in Chrome) |
| Next / previous tab (alt) | Ctrl+PgDn / PgUp | Cmd+Option+→ / ← | ✅ (Karabiner) |
| Back / forward | Alt+← / → | Cmd+[ / ] | ✅ (Karabiner) |
| Reload | Ctrl+R / F5 | Cmd+R / F5 | ✅ |
| Developer tools / console | F12, Ctrl+Shift+I / J | F12; Cmd+Option+I / J | ✅ (Karabiner) |

## VS Code

| Action | Windows | macOS | Status |
|---|---|---|---|
| Command palette | Ctrl+Shift+P | Cmd+Shift+P | ✅ |
| Quick open | Ctrl+P | Cmd+P | ✅ |
| Toggle sidebar | Ctrl+B | Cmd+B | ✅ |
| Toggle comment | Ctrl+/ | Cmd+/ | ✅ |
| Add next occurrence | Ctrl+D | Cmd+D | ✅ |
| Move line up / down | Alt+↑/↓ | Option+↑/↓ | ✅ |
| Settings | Ctrl+, | Cmd+, | ✅ |
| Toggle terminal | Ctrl+` | Ctrl+` | ✅ (Karabiner: Cmd+` becomes Ctrl+` in VS Code) |
| Focus terminal / editor | Ctrl+K / Ctrl+J | Cmd+K / Cmd+J | ✅ (`platform/macos/vscode/keybindings.json`) |
| Interrupt in terminal | Ctrl+C | Cmd+C | ✅ (`keybindings.json`: sends `^C` when nothing is selected) |
| Go to definition | F12 | F12 | ✅ (F-keys on the top row) |

## WezTerm and tmux

From `wezterm.lua` and `.tmux.conf`. These are the same keys on both systems.

| Action | Keys | Status |
|---|---|---|
| Split right / below | Alt+h / Alt+v | ✅ (needs Option as Alt, set in `wezterm.lua`) |
| Close pane | Alt+w | ✅ |
| Move between panes | Alt+←/→/↑/↓ | ✅ |
| Previous / next tab or window | Alt+Shift+←/→ | ✅ |
| Paste | Ctrl+V | ✅ (`Cmd+V` in macOS) |
| Copy | Ctrl+Shift+C | ✅ (`Cmd+Shift+C` in macOS) |
| Interrupt, history search, line start/end | Ctrl+C / R / A / E | ✅ (`Cmd+<letter>` forwarded as Ctrl) |
| Shift+arrows, Home/End, word delete in zsh | per `.zshrc` | ✅ (bindings load after oh-my-zsh) |

## OS

| Action | Windows | macOS | Status |
|---|---|---|---|
| Switch apps | Alt+Tab | Option+Tab | ✅ (AltTab) |
| Screenshot to clipboard | Win+Shift+S | Cmd+Ctrl+Shift+4 | ✅ (Karabiner) |
| Task manager | Ctrl+Shift+Esc | Cmd+Option+Esc | ✅ (Karabiner, opens Force Quit) |
| Clipboard history | Win+V | none built in | ➖ |
| Quit app | Alt+F4 | Cmd+Q | ✅ (Karabiner) |

## Open decisions

- **Win key on macOS: decided, Ctrl.** Win shortcuts (snapping, lock) are not
  used, so the key becomes a real Ctrl for macOS-native shortcuts. It is not
  the same physical press as Windows, which is why Chrome and VS Code still
  need Karabiner rules. To trial Hyper (Cmd+Ctrl+Option+Shift) instead, change
  that one key in VIA and bind Rectangle or any Win-style shortcuts to Hyper.
- **Function row: decided.** F1–F12 are on the top row of both base layers;
  media keys are on Fn.
- **Right-hand keys.** Right Ctrl sends Cmd and the right Alt sends Option on
  macOS, matching the left side. Revert them in VIA if that feels wrong.
- **Bluetooth versus USB.** VIA edits need USB, but the keymap is stored on the
  board and applies over Bluetooth.
