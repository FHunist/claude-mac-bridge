#!/usr/bin/env bash
# Delete a calendar event matched by title substring on a specific day.
# Restricting to one day keeps it from nuking a recurring series wholesale.
#
# Usage:
#   delete.sh "<calendar>" "<title substring>" "YYYY-MM-DD"
#
# - Deletes the FIRST event in <calendar> on that day whose summary contains the
#   substring. Echoes what it deleted, or "no match".
# - WARNING: deleting one occurrence of a Google recurring series can behave
#   unpredictably (may remove the whole series). Confirm first, and prefer editing
#   recurring meetings in Calendar.app directly.

set -euo pipefail

CAL="${1:?calendar required}"
SUB="${2:?title substring required}"
DAY="${3:?date required (YYYY-MM-DD)}"
Y=$((10#${DAY%%-*}))
M="${DAY#*-}"; M=$((10#${M%%-*}))
D=$((10#${DAY##*-}))

osascript \
  -e "on run argv" \
  -e "  set {calName, sub, yy, mm, dd} to argv" \
  -e "  tell application \"Calendar\"" \
  -e "    set d1 to (current date)" \
  -e "    set year of d1 to (yy as integer)" \
  -e "    set month of d1 to (mm as integer)" \
  -e "    set day of d1 to (dd as integer)" \
  -e "    set hours of d1 to 0" \
  -e "    set minutes of d1 to 0" \
  -e "    set seconds of d1 to 0" \
  -e "    set d2 to d1 + (1 * days)" \
  -e "    set theCal to (first calendar whose name is calName)" \
  -e "    set matches to (every event of theCal whose summary contains sub and start date ≥ d1 and start date < d2)" \
  -e "    if (count of matches) is 0 then return \"no match\"" \
  -e "    set ev to item 1 of matches" \
  -e "    set t to summary of ev" \
  -e "    delete ev" \
  -e "    return \"deleted: \" & t & \" on \" & (yy as string) & \"-\" & (mm as string) & \"-\" & (dd as string)" \
  -e "  end tell" \
  -e "end run" \
  -- "$CAL" "$SUB" "$Y" "$M" "$D"
