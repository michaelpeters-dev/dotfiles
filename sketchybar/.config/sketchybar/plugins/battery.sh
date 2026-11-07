#!/bin/bash
source "$CONFIG_DIR/colors.sh"
INFO="$(pmset -g batt)"
PCT="$(echo "$INFO" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')"
[ -z "$PCT" ] && exit 0

COLOR=$GREEN
case "$PCT" in
  9[0-9]|100) ICON= ;;
  [6-8][0-9]) ICON= ;;
  [3-5][0-9]) ICON= ;;
  [1-2][0-9]) ICON=; COLOR=$PEACH ;;
  *)          ICON=; COLOR=$RED ;;
esac
echo "$INFO" | grep -q 'AC Power' && { ICON=; COLOR=$GREEN; }

sketchybar --set "$NAME" icon="$ICON" icon.color=$COLOR label="${PCT}%"
