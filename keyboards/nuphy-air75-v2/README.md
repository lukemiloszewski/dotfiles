# NuPhy Air75 V2

VIA files for the NuPhy Air75 V2, edited at [usevia.app](https://usevia.app).

| File | Contents |
|---|---|
| `nuphy-air75-v2-via3.json` | NuPhy's VIA keyboard definition (matrix, lighting menu, custom keycodes). |
| `nuphy_air75_v2.layout.json` | Saved keymap: 6 layers. |

## Layers

| Layer | Use |
|---|---|
| 0 | Mac base, F1–F12 on the top row, modifiers remapped for Windows parity |
| 1 | Mac Fn, media keys |
| 2 | Windows base, F1–F12 on the top row |
| 3 | Windows Fn, media keys |
| 4 | Extra bindings (7 keys) |
| 5 | Unused |

## Windows parity on macOS

The same physical key presses should do the same thing on both systems, with
Windows as the reference. Layer 0 therefore differs from NuPhy's default Mac
layer; layers 2 and 3 are unchanged. See [`keymap/`](../../keymap/README.md).

| Physical key | Windows layer | Mac layer |
|---|---|---|
| Left Ctrl | Ctrl | Cmd |
| Left, next to Ctrl | Win | Ctrl |
| Left, next to space | Alt | Option |
| Right, next to space | Alt | Option |
| Right Ctrl | Ctrl | Cmd |

The top row is F1–F12 on both base layers; the media keys are on Fn. The
per-app remaps that firmware can't do are in `home/.config/karabiner/` and
`home/.config/wezterm/wezterm.lua`.

## Load and save

1. In VIA, open Settings and enable **Show Design tab**.
2. If the board isn't detected, go to **Design** and load `nuphy-air75-v2-via3.json`.
3. In **Configure → Save + Load**, use **Load Saved Layout** to apply `nuphy_air75_v2.layout.json`.
4. After changing keys, use **Save Current Layout** and replace `nuphy_air75_v2.layout.json` here.
