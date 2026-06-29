#!/bin/bash
# Add a reminder.  Usage:
#   add.sh "<list>" "<title>" [YYYY-MM-DD] [priority]
# priority: 0 none, 1 high, 5 medium, 9 low (default 0). Due optional (defaults 09:00 that day).
LIST="$1"; TITLE="$2"; DUE="${3:-}"; PRI="${4:-0}"
if [ -z "$LIST" ] || [ -z "$TITLE" ]; then
  echo "usage: add.sh \"<list>\" \"<title>\" [YYYY-MM-DD] [priority]" >&2; exit 1
fi
if [ -n "$DUE" ]; then
  Y="${DUE%%-*}"; rest="${DUE#*-}"; M="${rest%%-*}"; D="${rest#*-}"
else
  Y=""; M=""; D=""
fi
osascript - "$LIST" "$TITLE" "$Y" "$M" "$D" "$PRI" <<'EOF'
on run argv
  set lname to item 1 of argv
  set t to item 2 of argv
  set y to item 3 of argv
  set mo to item 4 of argv
  set d to item 5 of argv
  set p to (item 6 of argv) as integer
  tell application "Reminders"
    tell list lname
      if y is "" then
        make new reminder with properties {name:t, priority:p}
      else
        set dd to (current date)
        set day of dd to 1
        set hours of dd to 9
        set minutes of dd to 0
        set seconds of dd to 0
        set year of dd to (y as integer)
        set month of dd to (mo as integer)
        set day of dd to (d as integer)
        make new reminder with properties {name:t, due date:dd, priority:p}
      end if
    end tell
  end tell
end run
EOF
echo "added: \"$TITLE\" -> $LIST ${DUE:+(due $DUE)} pri=$PRI"
