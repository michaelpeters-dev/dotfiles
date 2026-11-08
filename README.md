# dotfiles

My macOS setup, themed Catppuccin Mocha everywhere:
AeroSpace (tiling) + SketchyBar (top bar) + JankyBorders + Ghostty + starship + Neovim.

## Install

```sh
cd ~/dotfiles
./setup.sh      # installs the Brewfile, links configs, themes macOS, sets the wallpaper
./push.sh       # first time only: pushes CSES + this repo to GitHub as private repos
```

`setup.sh` is safe to re-run. It backs up anything it replaces to `~/.dotfiles-backup/<date>/`.

## What's in here

| Folder | Links to | What it is |
|---|---|---|
| `aerospace/` | `~/.config/aerospace/aerospace.toml` | tiling window manager |
| `sketchybar/` | `~/.config/sketchybar/` | top bar: workspaces, app, coding time, problems solved, cpu, battery, clock |
| `borders/` | `~/.config/borders/bordersrc` | mauve border on the focused window |
| `ghostty/` | `~/.config/ghostty/config` | terminal |
| `starship/` | `~/.config/starship.toml` | prompt |
| `zsh/` | `~/.config/zsh/extras.zsh` | theme colors, aliases, tool setup (sourced from `~/.zshrc`) |
| `bat/` | `~/.config/bat/config` | `bat` theme |
| `wallpapers/` | | the Mocha mountains wallpaper |

Neovim lives in its own repo at `~/.config/nvim` (michaelpeters-dev/nvim-config), now using `catppuccin-mocha`.

## The bar

- **Coding time:** today's WakaTime total toward a 2h goal (8-cell bar; turns green at the goal). Click for the last 7 days. Change the goal with `WAKA_GOAL_SECONDS` in `sketchybarrc`.
- **Solved:** new solution files (`.cpp .py .java .rs ...`) committed today in any git repo under `~/code/cp`. Click for the week total and your daily streak. It updates every minute, so commit when you solve.
- Reload after edits: `sketchybar --reload`

## Keys (alt = option)

| Keys | Action |
|---|---|
| `alt-enter` | new Ghostty window |
| `alt-h/j/k/l` | focus left/down/up/right |
| `alt-shift-h/j/k/l` | move window |
| `alt-1..5` | switch workspace (1 code, 2 browser, 3 school, 4 chat, 5 misc) |
| `alt-shift-1..5` | send window to workspace |
| `alt-tab` | previous workspace |
| `alt-f` | fullscreen |
| `alt-/` | toggle tiles horizontal/vertical |
| `alt-,` | accordion layout |
| `alt-minus` / `alt-equal` | shrink / grow |
| `alt-shift-space` | float / tile window |
| `alt-shift-;` then `esc` | reload AeroSpace config |
| `ctrl-cmd-drag` | move any window by dragging anywhere |
| `cmd-d` / `cmd-shift-d` | Ghostty split right / down |

## Shell shortcuts

`cses` jump to CSES, `csnew 1068` start a problem from the template, `cpr a.cpp in1` compile and run with sanitizers,
`ll` / `lt` eza listings, `lg` lazygit, `v` nvim, `z <dir>` jump anywhere (zoxide), `ctrl-r` fuzzy history, `ctrl-t` fuzzy file.
