#!/usr/bin/env bash
# List upcoming Apple Calendar events via icalBuddy (fast, expands recurrences correctly).
#
# Usage:
#   list.sh                       # today through +7 days
#   list.sh 14                    # today through +N days
#   list.sh 2026-07-01 2026-07-31 # explicit date range (inclusive)
#
# Output: human-readable bullets (title, day/time, location). Notes/URLs/attendees
# are stripped (Google invites bury everything in Meet boilerplate otherwise).

set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

if ! command -v icalBuddy >/dev/null 2>&1; then
  echo "ERROR: icalBuddy not installed. Run: brew install ical-buddy" >&2
  exit 1
fi

case "${1:-}" in
  "")            RANGE=(eventsToday+7) ;;
  *[!0-9]*)      RANGE=("eventsFrom:${1}" "to:${2:?end date required for range}") ;;
  *)             RANGE=("eventsToday+${1}") ;;
esac

exec icalBuddy \
  -nc -nrd \
  -b "• " \
  -df "%a %Y-%m-%d" -tf "%H:%M" \
  -iep "datetime,title,location" \
  -eep "notes,url,attendees" \
  "${RANGE[@]}"
