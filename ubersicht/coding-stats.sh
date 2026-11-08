#!/bin/bash
# Data for the desktop widget: WakaTime (last 7 days) + problems solved (from git in ~/code/cp).
# Prints one JSON object. Used by ~/dotfiles/ubersicht/coding-stats.widget/index.jsx
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
CP="$HOME/code/cp"
GOAL="${WAKA_GOAL_SECONDS:-7200}"
DAYS=91   # heatmap window: 13 weeks

day() { date -v-"$1"d +%F 2>/dev/null || date -d "-$1 day" +%F; }

# ---------- WakaTime ----------
CFG="$HOME/.wakatime.cfg"
cfg() { awk -F'=' -v k="$1" '$1 ~ "^[ \t]*"k"[ \t]*$" {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}' "$CFG" 2>/dev/null; }
KEY="$(cfg api_key)"; API="$(cfg api_url)"; API="${API:-https://wakatime.com/api/v1}"; API="${API%/}"
WAKA='[]'
if [ -n "$KEY" ]; then
  J="$(curl -sf -m 10 -H "Authorization: Basic $(printf '%s' "$KEY" | base64)" "$API/users/current/summaries?range=last_7_days")"
  [ -n "$J" ] && WAKA="$(echo "$J" | jq -c '[.data[] | {d: .range.date, s: (.grand_total.total_seconds | floor)}]' 2>/dev/null || echo '[]')"
fi

# ---------- solves per day (new solution files committed) ----------
PER_DAY="$(
  for repo in "$CP"/*/; do
    [ -d "$repo/.git" ] || continue
    git -C "$repo" log --since="$DAYS days ago" --diff-filter=A --name-only \
      --date=format:%Y-%m-%d --pretty=format:'@%ad' \
      -- '*.cpp' '*.cc' '*.c' '*.py' '*.java' '*.rs' '*.kt' 2>/dev/null | sed "s|^\([^@]\)|$repo\1|"
  done | awk '
    /^@/ { d = substr($0, 2); next }
    NF && tolower($0) !~ /template/ { if (!seen[$0]++) n[d]++ }
    END { for (k in n) print k, n[k] }'
)"
count_on() { echo "$PER_DAY" | awk -v d="$1" '$1 == d {print $2; f=1} END {if (!f) print 0}'; }

HEAT=""; WEEK=0; STREAK=0; alive=1
for ((i = DAYS - 1; i >= 0; i--)); do
  d="$(day $i)"; c="$(count_on "$d")"
  HEAT+="{\"d\":\"$d\",\"c\":$c},"
  [ $i -lt 7 ] && WEEK=$((WEEK + c))
done
HEAT="[${HEAT%,}]"
for ((i = 0; i < DAYS; i++)); do
  c="$(count_on "$(day $i)")"
  if [ "$c" -gt 0 ]; then STREAK=$((STREAK + 1)); elif [ $i -gt 0 ]; then break; fi
done
TODAY="$(count_on "$(day 0)")"

# ---------- totals ----------
CSES=0
[ -d "$CP/cses/.git" ] && CSES="$(git -C "$CP/cses" ls-files -- '*.cpp' '*.py' '*.java' '*.rs' | grep -vi template | wc -l | tr -d ' ')"
LC=0
[ -d "$CP/leetcode/solutions" ] && LC="$(find "$CP/leetcode/solutions" -maxdepth 1 -type f ! -name '.*' | wc -l | tr -d ' ')"

cat <<EOF
{"goal":$GOAL,"waka":$WAKA,"today":$TODAY,"week":$WEEK,"streak":$STREAK,"cses":$CSES,"csesTotal":400,"leetcode":$LC,"heat":$HEAT}
EOF
