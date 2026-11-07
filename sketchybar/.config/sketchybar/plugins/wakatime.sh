#!/bin/bash
# Today's coding time from WakaTime vs the daily goal, plus a 7-day popup on click.
# Reads your API key from ~/.wakatime.cfg at runtime; the key is never copied anywhere.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
source "$CONFIG_DIR/colors.sh"

GOAL="${WAKA_GOAL_SECONDS:-7200}"
CFG="$HOME/.wakatime.cfg"
CACHE="${TMPDIR:-/tmp}/sketchybar_wakatime"

cfg() { awk -F'=' -v k="$1" '$1 ~ "^[ \t]*"k"[ \t]*$" {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}' "$CFG" 2>/dev/null; }
KEY="$(cfg api_key)"
API="$(cfg api_url)"; API="${API:-https://wakatime.com/api/v1}"; API="${API%/}"
AUTH="Authorization: Basic $(printf '%s' "$KEY" | base64)"

fmt() { local s=$1; printf '%dh %02dm' $((s / 3600)) $((s % 3600 / 60)); }
bar() { # $1 seconds -> 8-cell bar toward goal
  local filled=$(( $1 * 8 / GOAL )); [ $filled -gt 8 ] && filled=8
  local out="" i
  for ((i = 0; i < 8; i++)); do [ $i -lt $filled ] && out+="▰" || out+="▱"; done
  printf '%s' "$out"
}

if [ -z "$KEY" ]; then
  sketchybar --set "$NAME" label="wakatime: no key"; exit 0
fi

if [ "$SENDER" = "mouse.clicked" ]; then
  JSON="$(curl -sf -m 10 -H "$AUTH" "$API/users/current/summaries?range=last_7_days")"
  if [ -n "$JSON" ]; then
    i=0
    while IFS=$'\t' read -r day secs; do
      secs=${secs%.*}; name="$(date -j -f %Y-%m-%d "$day" +%a 2>/dev/null || echo "$day")"
      color=$SUBTEXT0; [ "$secs" -ge "$GOAL" ] && color=$GREEN
      [ $i -eq 6 ] && color=$MAUVE
      sketchybar --set wakatime.day.$i label="$name  $(bar "$secs")  $(fmt "$secs")" label.color=$color
      i=$((i + 1))
    done < <(echo "$JSON" | jq -r '.data[] | [.range.date, (.grand_total.total_seconds|tostring)] | @tsv')
  fi
  sketchybar --set "$NAME" popup.drawing=toggle
  exit 0
fi

JSON="$(curl -sf -m 8 -H "$AUTH" "$API/users/current/status_bar/today")"
SECS="$(echo "$JSON" | jq -r '.data.grand_total.total_seconds // empty' 2>/dev/null)"
SECS="${SECS%.*}"

if [ -z "$SECS" ]; then
  # offline or API hiccup: keep the last value
  [ -f "$CACHE" ] && sketchybar --set "$NAME" label="$(cat "$CACHE")"
  exit 0
fi

LABEL="$(fmt "$SECS") $(bar "$SECS")"
echo "$LABEL" > "$CACHE"
COLOR=$TEXT; [ "$SECS" -ge "$GOAL" ] && COLOR=$GREEN
sketchybar --set "$NAME" label="$LABEL" label.color=$COLOR
