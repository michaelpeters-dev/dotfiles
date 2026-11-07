# Michael's shell extras: Catppuccin theme, dev tools, shortcuts.
# Sourced from ~/.zshrc (setup.sh adds one line at the end). Edit here, not in .zshrc.

export PATH="/opt/homebrew/bin:$PATH"
export EDITOR=nvim
export VISUAL=nvim

# bits/stdc++.h shim for Apple clang (moved from ~/programming/cpp)
export CPATH="$HOME/code/cp/toolkit/include${CPATH:+:$CPATH}"

# ---------- theme ----------
export BAT_THEME="Catppuccin Mocha"
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a,border:#6c7086 \
--border=rounded --layout=reverse --height=40%"
command -v fd >/dev/null && export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'

# ---------- shortcuts ----------
if command -v eza >/dev/null; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -l --icons --git --group-directories-first'
  alias la='eza -la --icons --git --group-directories-first'
  alias lt='eza --tree --level=2 --icons --git-ignore'
fi
alias v='nvim'
alias lg='lazygit'
alias code-dir='cd ~/code'
alias cses='cd ~/code/cp/cses'
alias school='cd ~/School'
alias dot='cd ~/dotfiles'
alias bar-reload='sketchybar --reload'

# compile + run a CP solution with sanitizers: cpr a.cpp [input]
alias cpr='~/code/cp/toolkit/run.sh'

# start a CSES problem from the template: csnew 1068 [folder]
csnew() {
  [ -z "$1" ] && { echo "usage: csnew <task-id> [folder]"; return 1; }
  local dir="${2:-.}"; mkdir -p "$dir"
  local f="$dir/$1.cpp"
  [ -e "$f" ] || cp ~/code/cp/cses/templates/template.cpp "$f"
  nvim "$f"
}

# ---------- tools ----------
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
command -v fzf >/dev/null && source <(fzf --zsh 2>/dev/null)

if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6c7086'
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

command -v starship >/dev/null && eval "$(starship init zsh)"

# syntax highlighting must load last
[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
