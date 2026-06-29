#!/usr/bin/env bash
# Create a new Apple Calendar event (writes via AppleScript; syncs to Google for
# CalDAV calendars like "Calendar"). Easily reversible with delete.sh.
#
# Usage:
#   add.sh "<calendar>" "<title>" "YYYY-MM-DD HH:MM" [duration_min | allday] ["location"] ["RRULE"]
#
# - <calendar> empty string ("") defaults to $DEFAULT_CAL (set below).
# - duration: minutes (default 60), or the literal "allday" for an all-day event.
# - RRULE (optional): iCal recurrence rule for repeating events, e.g.
#     "FREQ=WEEKLY;BYDAY=MO,TU,WE,FR,SA"  or  "FREQ=DAILY;INTERVAL=1".
#   The start date should fall on a day the rule includes. NOTE: editing/deleting a
#   single occurrence of a recurring series via AppleScript is unreliable; change
#   recurring blocks in Calendar.app, and only create them here. Recurrence is also
#   only reliable on iCloud calendars; Google-synced calendars may drop the RRULE.
# - Uses the Mac's local timezone.
# - A default display alert is attached: 15 min before for timed events, 9:00 AM
#   day-of for all-day events. (Whether it pushes is gated by your macOS Focus settings.)
#
# Examples:
#   add.sh "" "Coffee" "2026-06-26 14:00" 30 "Main St Cafe"
#   add.sh "Personal" "Dentist" "2026-07-03 11:00" 45
#   add.sh "" "Travel day" "2026-07-10 00:00" allday

set -euo pipefail

# ── CONFIG ── default calendar used when the first arg is "".
# Set to the Calendar.app calendar you write to most ("Calendar", "Home", "iCloud",
# or the name of a Google-synced calendar).
DEFAULT_CAL="Calendar"

CAL="${1-}"
[[ -z "$CAL" ]] && CAL="$DEFAULT_CAL"
TITLE="${2:?title required}"
START="${3:?start required (YYYY-MM-DD HH:MM)}"
DUR="${4:-60}"
LOC="${5:-}"
RRULE="${6:-}"

DATE_PART="${START%% *}"; TIME_PART="${START##* }"
[[ "$START" == *" "* ]] || TIME_PART="00:00"
Y=$((10#${DATE_PART%%-*}))
M="${DATE_PART#*-}"; M=$((10#${M%%-*}))
D=$((10#${DATE_PART##*-}))
HH=$((10#${TIME_PART%%:*}))
MN=$((10#${TIME_PART##*:}))

ALLDAY="false"; DURMIN=60
if [[ "$DUR" == "allday" ]]; then ALLDAY="true"; else DURMIN=$((10#$DUR)); fi

osascript \
  -e "on run argv" \
  -e "  set {calName, evTitle, yy, mm, dd, hh, mn, allday, durmin, loc, rrule} to argv" \
  -e "  tell application \"Calendar\"" \
  -e "    set s to (current date)" \
  -e "    set year of s to (yy as integer)" \
  -e "    set month of s to (mm as integer)" \
  -e "    set day of s to (dd as integer)" \
  -e "    set hours of s to (hh as integer)" \
  -e "    set minutes of s to (mn as integer)" \
  -e "    set seconds of s to 0" \
  -e "    set e to s + ((durmin as integer) * minutes)" \
  -e "    set theCal to (first calendar whose name is calName)" \
  -e "    if allday is \"true\" then" \
  -e "      set newEv to (make new event at end of events of theCal with properties {summary:evTitle, start date:s, end date:(s + 1 * days), allday event:true})" \
  -e "    else" \
  -e "      set newEv to (make new event at end of events of theCal with properties {summary:evTitle, start date:s, end date:e})" \
  -e "    end if" \
  -e "    if loc is not \"\" then set location of newEv to loc" \
  -e "    if rrule is not \"\" then set recurrence of newEv to rrule" \
  -e "    if allday is \"true\" then" \
  -e "      make new display alarm at end of display alarms of newEv with properties {trigger interval:540}" \
  -e "    else" \
  -e "      make new display alarm at end of display alarms of newEv with properties {trigger interval:-15}" \
  -e "    end if" \
  -e "    return \"added: \" & evTitle & \" -> \" & calName & \" (\" & (start date of newEv as string) & \", alert set)\"" \
  -e "  end tell" \
  -e "end run" \
  -- "$CAL" "$TITLE" "$Y" "$M" "$D" "$HH" "$MN" "$ALLDAY" "$DURMIN" "$LOC" "$RRULE"
