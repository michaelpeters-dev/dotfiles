#!/bin/bash
# One-time setup for Michael's Mac: installs tools, links dotfiles, themes macOS.
# Safe to re-run. Usage: cd ~/dotfiles && ./setup.sh
# Options: KEEP_P10K=1 ./setup.sh   keep Powerlevel10k instead of switching to starship

set -u
DOT="$(cd "$(dirname "$0")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$HOME/.dotfiles-backup/$STAMP"
ok()   { printf '\033[38;2;166;227;161m  ok\033[0m  %s\n' "$*"; }
warn() { printf '\033[38;2;249;226;175m warn\033[0m %s\n' "$*"; }
step() { printf '\n\033[38;2;203;166;247m==> %s\033[0m\n' "$*"; }

[ "$(uname)" = "Darwin" ] || { echo "macOS only"; exit 1; }
export PATH="/opt/homebrew/bin:$PATH"

# ------------------------------------------------------------------
step "1/7  Homebrew packages (Brewfile)"
if ! command -v brew >/dev/null; then
  warn "Homebrew not found. Install it from https://brew.sh then re-run."; exit 1
fi
if ! brew bundle --file="$DOT/Brewfile"; then
  warn "Some packages failed. If it mentions Command Line Tools, update them in"
  warn "System Settings > General > Software Update, then re-run ./setup.sh"
fi

# ------------------------------------------------------------------
step "2/7  Fix old folder paths in your shell files"
# Folders moved during the 2026-11-07 reorg (see ~/code/MOVE_LOG.md)
PAIRS=(
  "programming/cpp|code/cp/toolkit"
  "Desktop/Personal/CSES|code/cp/cses"
  "Desktop/cses|code/cp/cses/templates"
  "applyer|code/projects/applyer"
  "code/peer-to-peer-inference|code/projects/peer-to-peer-inference"
  "Desktop/Programs/aq|code/work/tgt/aq"
  "Desktop/qwerty|code/work/tinker/qwerty"
  "Desktop/Brain|code/projects/brain"
  "Desktop/NeetCode150|code/cp/neetcode150"
  "Desktop/researchforme|code/projects/researchforme"
  "Desktop/system-design-primer|code/learning/system-design-primer"
)
for f in "$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.zshenv" "$HOME/.bashrc" "$HOME/.bash_profile"; do
  [ -f "$f" ] || continue
  mkdir -p "$BACKUP"; cp "$f" "$BACKUP/$(basename "$f")"
  for pair in "${PAIRS[@]}"; do
    old="${pair%%|*}"; new="${pair##*|}"
    for pre in '~/' '$HOME/' '${HOME}/' "$HOME/"; do
      OLD="$pre$old" NEW="$pre$new" perl -pi -e 's/\Q$ENV{OLD}\E(?![\w-])/$ENV{NEW}/g' "$f"
    done
  done
  ok "updated paths in $(basename "$f") (backup in $BACKUP)"
done
left="$(grep -nE 'Desktop/(Programs|Programming|Personal|CPP|Labs|School|Classes)' "$HOME/.zshrc" 2>/dev/null)"
[ -n "$left" ] && { warn "these .zshrc lines still point at old folders, fix by hand:"; echo "$left"; }
if ls "$HOME/Library/LaunchAgents/"*.plist >/dev/null 2>&1; then
  hits="$(grep -lE 'Desktop/|/applyer|programming/cpp|code/peer-to-peer' "$HOME/Library/LaunchAgents/"*.plist 2>/dev/null)"
  [ -n "$hits" ] && { warn "launch agents that reference old paths (check these):"; echo "$hits"; }
fi

# ------------------------------------------------------------------
step "3/7  Shell: starship prompt + extras"
ZRC="$HOME/.zshrc"; touch "$ZRC"
if [ "${KEEP_P10K:-0}" != "1" ]; then
  # turn off Powerlevel10k (starship replaces it); the lines are commented, not deleted
  perl -0pi -e 's/^(if \[\[ -r .*p10k-instant-prompt.*\n.*\n)fi\n/join("", map { "# [p10k off] $_\n" } split(m{\n}, "$1fi"))/me' "$ZRC"
  perl -pi -e 's/^(\s*ZSH_THEME=.*powerlevel10k.*)$/# [p10k off] $1\nZSH_THEME=""/; s/^(?!# \[p10k off\])(.*(?:\.p10k\.zsh|powerlevel10k\.zsh-theme).*)$/# [p10k off] $1/' "$ZRC"
  ok "Powerlevel10k disabled in .zshrc (search for '[p10k off]' to undo)"
fi
LINE='[ -f ~/.config/zsh/extras.zsh ] && source ~/.config/zsh/extras.zsh'
grep -qF "$LINE" "$ZRC" || { printf '\n# theme, tools and shortcuts (managed in ~/dotfiles/zsh)\n%s\n' "$LINE" >> "$ZRC"; }
ok "extras.zsh sourced from .zshrc"

# ------------------------------------------------------------------
step "4/7  Link dotfiles into ~/.config (stow)"
PKGS=(aerospace sketchybar borders ghostty starship zsh bat)
for pkg in "${PKGS[@]}"; do
  # move any existing real files out of the way first
  (cd "$DOT/$pkg" && find . -type f) | while read -r rel; do
    tgt="$HOME/${rel#./}"
    if [ -e "$tgt" ] && [ ! -L "$tgt" ]; then
      mkdir -p "$BACKUP/$(dirname "${rel#./}")"; mv "$tgt" "$BACKUP/${rel#./}"
      warn "backed up existing ${rel#./}"
    fi
  done
done
if command -v stow >/dev/null; then
  stow -d "$DOT" -t "$HOME" -R "${PKGS[@]}" && ok "linked: ${PKGS[*]}"
else
  warn "stow missing, linking by hand"
  for pkg in "${PKGS[@]}"; do
    (cd "$DOT/$pkg" && find . -type f) | while read -r rel; do
      mkdir -p "$HOME/$(dirname "${rel#./}")"; ln -sfn "$DOT/$pkg/${rel#./}" "$HOME/${rel#./}"
    done
  done
fi
chmod +x "$HOME/.config/sketchybar/sketchybarrc" "$HOME/.config/sketchybar/plugins/"*.sh "$HOME/.config/borders/bordersrc" 2>/dev/null

# bat theme (Catppuccin Mocha)
if command -v bat >/dev/null; then
  TD="$(bat --config-dir)/themes"; mkdir -p "$TD"
  curl -fsSL -o "$TD/Catppuccin Mocha.tmTheme" \
    "https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Mocha.tmTheme" \
    && bat cache --build >/dev/null && ok "bat theme installed" || warn "couldn't download bat theme (offline?)"
fi

# ------------------------------------------------------------------
step "5/7  macOS settings"
osascript -e 'tell application "System Events" to set autohide menu bar of dock preferences to true' >/dev/null 2>&1 && ok "menu bar auto-hides (SketchyBar replaces it)"
osascript -e 'tell application "System Events" to set autohide of dock preferences to true' >/dev/null 2>&1
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.4
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock expose-group-apps -bool true          # recommended for AeroSpace
defaults write com.apple.spaces spans-displays -bool true           # recommended for AeroSpace (needs logout)
defaults write -g NSWindowShouldDragOnGesture -bool true            # ctrl+cmd+drag moves any window
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string Nlsv
defaults write com.apple.finder NewWindowTarget -string PfLo
defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/code/"
mkdir -p "$HOME/Media/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Media/Screenshots"  # keeps the Desktop clean
killall Dock Finder SystemUIServer >/dev/null 2>&1
ok "dock, keyboard, Finder and screenshot settings applied"

# ------------------------------------------------------------------
step "6/7  Wallpaper"
WP="$DOT/wallpapers/catppuccin-mocha-mountains.png"
osascript -e "tell application \"System Events\" to tell every desktop to set picture to POSIX file \"$WP\"" >/dev/null 2>&1 \
  && ok "wallpaper set on every display" || warn "set it by hand: System Settings > Wallpaper > Add Folder > ~/dotfiles/wallpapers"

# ------------------------------------------------------------------
step "7/7  Start the bar, borders and tiling"
brew services restart sketchybar >/dev/null 2>&1 && ok "SketchyBar running" || warn "SketchyBar not installed yet (see step 1)"
brew services restart borders    >/dev/null 2>&1 && ok "borders running"    || warn "borders not installed yet (see step 1)"
open -a AeroSpace 2>/dev/null && ok "AeroSpace launched" || warn "AeroSpace not installed yet"

cat <<'EOF'

Done. Last manual bits:
  1. Grant AeroSpace accessibility access when macOS asks
     (System Settings > Privacy & Security > Accessibility).
  2. Open Ghostty and pin it to the Dock; quit iTerm if you like.
  3. Open nvim once so lazy.nvim installs the catppuccin plugin.
  4. Log out and back in once (for the "displays span spaces" setting).
  5. Run ./push.sh to push CSES and these dotfiles to GitHub (private).
EOF
