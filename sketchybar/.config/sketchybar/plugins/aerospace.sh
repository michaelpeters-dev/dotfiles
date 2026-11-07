#!/bin/bash
# Highlight the focused AeroSpace workspace. $1 = workspace id
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
source "$CONFIG_DIR/colors.sh"
FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}"

if [ "$1" = "$FOCUSED" ]; then
  sketchybar --set "$NAME" background.drawing=on label.color=$CRUST
else
  sketchybar --set "$NAME" background.drawing=off label.color=$OVERLAY0
fi
