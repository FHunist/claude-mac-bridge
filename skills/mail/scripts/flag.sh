#!/usr/bin/env bash
# Flag (or unflag) an Apple Mail message by subject substring: the triage marker.
# Fully reversible: re-run with "off" to clear. Touches flags only; never sends,
# deletes, archives, or changes read status.
#
# Usage:
#   flag.sh "<account>" "<subject substring>" [on|off] [color]
#
# - Matches the first message (within the 40 most recent) in that account's inbox
#   whose subject contains the substring (case-insensitive).
# - color: red orange yellow green blue purple grey  (default red). Used when on.
# - Examples:
#     flag.sh "Work" "Q3 budget review" on red
#     flag.sh "Work" "Q3 budget review" off

set -euo pipefail

ACCT="${1:?account required}"
SUB="${2:?subject substring required}"
STATE="${3:-on}"
COLOR="${4:-red}"

case "$COLOR" in
  red) IDX=0 ;; orange) IDX=1 ;; yellow) IDX=2 ;; green) IDX=3 ;;
  blue) IDX=4 ;; purple) IDX=5 ;; grey|gray) IDX=6 ;; *) IDX=0 ;;
esac

osascript \
  -e 'on run argv' \
  -e '  set {acctName, sub, state, colorIdx} to argv' \
  -e '  tell application "Mail"' \
  -e '    set acct to account acctName' \
  -e '    set ib to missing value' \
  -e '    repeat with mbName in {"INBOX", "Inbox", "All Mail"}' \
  -e '      try' \
  -e '        set ib to mailbox (mbName as string) of acct' \
  -e '        exit repeat' \
  -e '      end try' \
  -e '    end repeat' \
  -e '    if ib is missing value then return "no inbox for " & acctName' \
  -e '    set k to 40' \
  -e '    set subs to {}' \
  -e '    try' \
  -e '      set subs to subject of messages 1 thru k of ib' \
  -e '    on error' \
  -e '      set k to (count of messages of ib)' \
  -e '      if k > 0 then set subs to subject of messages 1 thru k of ib' \
  -e '    end try' \
  -e '    repeat with i from 1 to (count of subs)' \
  -e '      if (item i of subs) contains sub then' \
  -e '        set m to message i of ib' \
  -e '        if state is "on" then' \
  -e '          set flagged status of m to true' \
  -e '          set flag index of m to (colorIdx as integer)' \
  -e '        else' \
  -e '          set flagged status of m to false' \
  -e '          set flag index of m to -1' \
  -e '        end if' \
  -e '        return "flagged(" & state & "): " & (item i of subs)' \
  -e '      end if' \
  -e '    end repeat' \
  -e '    return "no match for: " & sub' \
  -e '  end tell' \
  -e 'end run' \
  -- "$ACCT" "$SUB" "$STATE" "$IDX"
