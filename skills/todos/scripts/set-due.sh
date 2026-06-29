#!/usr/bin/env bash
# Set/modify the due date (and time) of an existing OPEN reminder.
# Unlike add.sh, this supports a time-of-day and edits in place (no recreate).
#
# Usage:
#   set-due.sh "<list>" "<title substring>" "YYYY-MM-DD[ HH:MM]" [priority]
#
# Examples:
#   set-due.sh "Reminders" "File taxes" "2026-06-24 15:00"
#   set-due.sh "Work" "Submit report" "2026-07-31" 1
#
# Notes:
# - Time defaults to 09:00 if omitted. Uses the Mac's local timezone.
# - priority: 0 none / 1 high / 5 med / 9 low (optional; left unchanged if omitted).
# - Matches the FIRST open reminder in <list> whose name contains <substring>.

set -euo pipefail

LIST="${1:?list required}"
SUBSTR="${2:?title substring required}"
WHEN="${3:?datetime required (YYYY-MM-DD[ HH:MM])}"
PRIO="${4:-}"

DATE_PART="${WHEN%% *}"
TIME_PART="09:00"
[[ "$WHEN" == *" "* ]] && TIME_PART="${WHEN##* }"

Y="${DATE_PART%%-*}"
M="${DATE_PART#*-}"; M="${M%%-*}"
D="${DATE_PART##*-}"
HH="${TIME_PART%%:*}"
MM="${TIME_PART##*:}"

# strip leading zeros so AppleScript doesn't read them as octal
Y=$((10#$Y)); M=$((10#$M)); D=$((10#$D)); HH=$((10#$HH)); MM=$((10#$MM))

osascript \
  -e "on run argv" \
  -e "  set {listName, sub, yy, mm, dd, hh, mn, prio} to argv" \
  -e "  tell application \"Reminders\"" \
  -e "    set theDate to current date" \
  -e "    set year of theDate to (yy as integer)" \
  -e "    set month of theDate to (mm as integer)" \
  -e "    set day of theDate to (dd as integer)" \
  -e "    set hours of theDate to (hh as integer)" \
  -e "    set minutes of theDate to (mn as integer)" \
  -e "    set seconds of theDate to 0" \
  -e "    set r to (first reminder of list listName whose name contains sub and completed is false)" \
  -e "    set due date of r to theDate" \
  -e "    set remind me date of r to theDate" \
  -e "    if prio is not \"\" then set priority of r to (prio as integer)" \
  -e "    return \"set due: \" & (name of r) & \" -> \" & (due date of r as string)" \
  -e "  end tell" \
  -e "end run" \
  -- "$LIST" "$SUBSTR" "$Y" "$M" "$D" "$HH" "$MM" "$PRIO"
