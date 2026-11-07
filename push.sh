#!/bin/bash
# Push the two repos from the overnight reorg to GitHub, both PRIVATE.
# Touches only these two repos. No other remotes are changed.
set -euo pipefail
export PATH="/opt/homebrew/bin:$PATH"
OWNER="michaelpeters-dev"

gh auth status >/dev/null 2>&1 || gh auth login

echo "==> CSES: make private and push"
gh repo edit "$OWNER/CSES" --visibility private --accept-visibility-change-consequences
git -C "$HOME/code/cp/cses" push origin main

echo "==> dotfiles: create private repo and push"
if gh repo view "$OWNER/dotfiles" >/dev/null 2>&1; then
  git -C "$HOME/dotfiles" remote get-url origin >/dev/null 2>&1 \
    || git -C "$HOME/dotfiles" remote add origin "https://github.com/$OWNER/dotfiles.git"
  git -C "$HOME/dotfiles" push -u origin main
else
  gh repo create "$OWNER/dotfiles" --private --source "$HOME/dotfiles" --remote origin --push
fi

echo "Done: github.com/$OWNER/CSES and github.com/$OWNER/dotfiles (both private)"
