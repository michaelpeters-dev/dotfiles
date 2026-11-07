#!/bin/bash
# Problems solved = new solution files committed in any git repo under ~/code/cp.
# Click for this week's total and your daily streak.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:$PATH"
source "$CONFIG_DIR/colors.sh"
CP="$HOME/code/cp"

# count new solution files committed between two git dates
count() {
  local args=(--since="$1"); [ -n "$2" ] && args+=(--until="$2")
  for repo in "$CP"/*/; do
    [ -d "$repo/.git" ] || continue
    git -C "$repo" log "${args[@]}" --diff-filter=A --name-only --pretty=format: \
      -- '*.cpp' '*.cc' '*.c' '*.py' '*.java' '*.rs' '*.kt' 2>/dev/null \
      | grep -v -i -e 'template' -e '^$' | sed "s|^|$repo|"
  done | sort -u | wc -l | tr -d ' '
}

if [ "$SENDER" = "mouse.clicked" ]; then
  WEEK="$(count '7 days ago')"
  STREAK=0
  # today counts if you solved something; otherwise the streak is still alive from yesterday
  for ((d = 0; d < 365; d++)); do
    day="$(date -v-${d}d +%Y-%m-%d)"
    n="$(count "$day 00:00" "$day 23:59:59")"
    if [ "$n" -gt 0 ]; then STREAK=$((STREAK + 1)); elif [ $d -gt 0 ]; then break; fi
  done
  sketchybar --set solved.week label="last 7 days: $WEEK solved" \
             --set solved.streak label="streak: $STREAK day$([ $STREAK -eq 1 ] || echo s)" label.color=$YELLOW \
             --set "$NAME" popup.drawing=toggle
  exit 0
fi

TODAY="$(count midnight)"
COLOR=$TEXT; [ "$TODAY" -gt 0 ] && COLOR=$YELLOW
sketchybar --set "$NAME" label="$TODAY solved" label.color=$COLOR
