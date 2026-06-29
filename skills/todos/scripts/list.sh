#!/bin/bash
# List all OPEN (incomplete) Apple Reminders across every list.
# Output: one line per reminder -> LIST ||| TITLE ||| DUE ||| PRIORITY
# priority: 0 none, 1 high, 5 medium, 9 low.  empty DUE = no due date.
osascript <<'EOF'
tell application "Reminders"
  set out to ""
  repeat with l in lists
    set lname to name of l
    repeat with r in (reminders of l whose completed is false)
      set rname to name of r
      try
        set dd to (due date of r) as string
      on error
        set dd to ""
      end try
      try
        set pr to (priority of r) as string
      on error
        set pr to "0"
      end try
      set out to out & lname & " ||| " & rname & " ||| " & dd & " ||| " & pr & linefeed
    end repeat
  end repeat
  return out
end tell
EOF
