#!/usr/bin/env bash
# Read recent Apple Mail messages (fast bulk fetch; no slow unified-inbox count).
# Reads from the Mail.app accounts named in DEFAULT_ACCOUNTS, or one passed as an arg.
#
# Usage:
#   list.sh                  # default account(s), 10 most recent each
#   list.sh Work             # one account, 10 most recent
#   list.sh Work 20          # one account, N most recent
#
# The account names must match what Mail.app shows under Mail > Settings > Accounts
# (the "Description" of each account, e.g. "iCloud", "Gmail", "Work").
# Output per account: READ/UNREAD | date | sender | subject  (subject is what
# flag.sh matches on). Read-only.

set -euo pipefail

# ── CONFIG ── account(s) read when no account arg is given. Use the exact names
# from Mail > Settings > Accounts. Add more to widen the default sweep, e.g.
#   DEFAULT_ACCOUNTS=("Work" "iCloud" "Gmail")
DEFAULT_ACCOUNTS=("iCloud")

ACCT="${1:-}"
COUNT="${2:-10}"
if [[ -n "$ACCT" ]]; then ACCOUNTS=("$ACCT"); else ACCOUNTS=("${DEFAULT_ACCOUNTS[@]}"); fi

osascript \
  -e 'on run argv' \
  -e '  set k to (item 1 of argv) as integer' \
  -e '  set accts to rest of argv' \
  -e '  tell application "Mail"' \
  -e '    set out to ""' \
  -e '    repeat with an in accts' \
  -e '      set acctName to an as string' \
  -e '      try' \
  -e '        set acct to account acctName' \
  -e '        set ib to missing value' \
  -e '        repeat with mbName in {"INBOX", "Inbox", "All Mail"}' \
  -e '          try' \
  -e '            set ib to mailbox (mbName as string) of acct' \
  -e '            exit repeat' \
  -e '          end try' \
  -e '        end repeat' \
  -e '        if ib is missing value then' \
  -e '          set out to out & "## " & acctName & " (no inbox found)" & linefeed' \
  -e '        else' \
  -e '          set kk to k' \
  -e '          set subs to {}' \
  -e '          try' \
  -e '            set subs to subject of messages 1 thru kk of ib' \
  -e '            set sndrs to sender of messages 1 thru kk of ib' \
  -e '            set dts to date received of messages 1 thru kk of ib' \
  -e '            set rds to read status of messages 1 thru kk of ib' \
  -e '          on error' \
  -e '            set kk to (count of messages of ib)' \
  -e '            if kk > k then set kk to k' \
  -e '            if kk > 0 then' \
  -e '              set subs to subject of messages 1 thru kk of ib' \
  -e '              set sndrs to sender of messages 1 thru kk of ib' \
  -e '              set dts to date received of messages 1 thru kk of ib' \
  -e '              set rds to read status of messages 1 thru kk of ib' \
  -e '            end if' \
  -e '          end try' \
  -e '          set out to out & "## " & acctName & linefeed' \
  -e '          set i to 1' \
  -e '          repeat with s in subs' \
  -e '            set marker to "[read]  "' \
  -e '            if (item i of rds) is false then set marker to "[UNREAD]"' \
  -e '            set out to out & marker & " " & (item i of dts as string) & " | " & (item i of sndrs) & " | " & (s as string) & linefeed' \
  -e '            set i to i + 1' \
  -e '          end repeat' \
  -e '          if (count of subs) is 0 then set out to out & "(no messages)" & linefeed' \
  -e '          set out to out & linefeed' \
  -e '        end if' \
  -e '      on error errm' \
  -e '        set out to out & "## " & acctName & " (error: " & errm & ")" & linefeed' \
  -e '      end try' \
  -e '    end repeat' \
  -e '    return out' \
  -e '  end tell' \
  -e 'end run' \
  -- "$COUNT" "${ACCOUNTS[@]}"
