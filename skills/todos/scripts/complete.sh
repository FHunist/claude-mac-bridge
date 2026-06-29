#!/bin/bash
# Mark the first OPEN reminder in <list> whose name contains <substring> as completed.
# Usage: complete.sh "<list>" "<title substring>"
LIST="$1"; MATCH="$2"
if [ -z "$LIST" ] || [ -z "$MATCH" ]; then
  echo "usage: complete.sh \"<list>\" \"<title substring>\"" >&2; exit 1
fi
osascript - "$LIST" "$MATCH" <<'EOF'
on run argv
  set lname to item 1 of argv
  set m to item 2 of argv
  tell application "Reminders"
    tell list lname
      set rs to (reminders whose completed is false and name contains m)
      if (count of rs) is 0 then return "no match for \"" & m & "\" in " & lname
      set theOne to item 1 of rs
      set completed of theOne to true
      return "completed: " & (name of theOne)
    end tell
  end tell
end run
EOF
