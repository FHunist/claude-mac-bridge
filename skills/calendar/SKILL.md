---
name: calendar
description: Read and manage your Apple Calendar (including Google/Exchange/iCloud calendars synced into Calendar.app) from a Mac. Use to see your schedule, find a free slot, add an event, or delete one.
---

# Calendar (Apple Calendar)

Reads and writes Apple Calendar through helper scripts in this skill's `scripts/` dir. Mac-only: it talks to Calendar.app, which syncs your Google / Exchange / iCloud calendars locally. Reads go through **icalBuddy** (fast, expands recurring events correctly); writes go through **AppleScript** (and sync back out for CalDAV calendars). This will not run in a cloud environment.

> **Personalize first:** set `DEFAULT_CAL` at the top of `scripts/add.sh` to the calendar you write to most. Calendar names below (`Personal`, `Work`, etc.) are placeholders for whatever your Calendar.app shows in the left sidebar.

## On invocation (the daily routine)
Run these in order. The goal is to plan the day and look ahead, not to dump a list.

1. **Anchor to the real now.** Run `date "+%A %Y-%m-%d %H:%M %Z"` first and treat it as ground truth for the current time, today's date, and the weekday. Never assume the date: gap-finding and "what's next" depend on the actual time, and the weekday decides step 4.
2. **Lay out today.** `bash ~/.claude/skills/calendar/scripts/list.sh 0` (today only). Present it as a timeline in order with times and locations. Mark what is **already past** vs **still ahead** relative to step 1, and call out the **next imminent thing**.
3. **Find the gaps.** Compute the free blocks between events within the working day (default roughly 09:00 to 18:00, but respect events outside it). List each open gap with its length (e.g. "11:00 to 13:30, 2.5h free"), accounting for travel time when consecutive events are in different locations. Then ask what to do with the gaps (deep work, errands, the day's todos, prep for the next meeting) and offer to block them via `add.sh`.
4. **Look ahead.**
   - **Mon to Thu:** preview the **rest of this week**: `list.sh <tomorrow YYYY-MM-DD> <coming Sunday YYYY-MM-DD>` (compute both from step 1's date), grouped by day. Flag anything needing prep or an early start.
   - **Friday or weekend:** preview **all of next week** instead: `list.sh <next Monday> <next Sunday>`, so the weekend starts with the week in view.

### Ad-hoc reads
`bash ~/.claude/skills/calendar/scripts/list.sh [days | <start YYYY-MM-DD> <end YYYY-MM-DD>]`
- No arg, today through +7 days. `0`, today only. Integer N, today through +N days. Two dates, explicit inclusive range.
- Output is bullets: title, day + time, location. Fast (sub-second).
- For "when am I free?" / "find a slot", read the range and reason over the gaps as in step 3.

## Adding an event
`bash ~/.claude/skills/calendar/scripts/add.sh "<calendar>" "<title>" "YYYY-MM-DD HH:MM" [duration_min | allday] ["location"] ["RRULE"]`
- `<calendar>` empty `""` defaults to `DEFAULT_CAL` (set in the script). Pass any writable calendar name to override.
- duration: minutes (default 60), or the literal `allday`. Uses the Mac's local timezone.
- A **default alert is attached automatically**: 15 min before (timed) / 9:00 AM day-of (all-day). Whether it actually pushes is gated by your macOS Focus settings.
- 6th arg is an optional iCal RRULE for repeats. See **Recurring events** below.
- Example: `add.sh "" "Coffee" "2026-06-26 14:00" 30 "Main St Cafe"`

## Deleting an event
`bash ~/.claude/skills/calendar/scripts/delete.sh "<calendar>" "<title substring>" "YYYY-MM-DD"`
- Deletes the first event in that calendar on that day whose title contains the substring; echoes what it deleted or "no match".

## Recurring events
Pass an iCal RRULE as `add.sh`'s 6th arg, e.g. `add.sh "Personal" "Gym" "2026-06-26 07:00" 90 "" "FREQ=WEEKLY;BYDAY=MO,TU,WE,FR,SA"`.
- **Recurrence is only reliable on iCloud calendars.** A Google-synced calendar may **silently drop the RRULE** (`recurrence` reads back `missing value`) and you get a single event. Keep recurring blocks on an iCloud calendar.
- **Editing/deleting a recurring series via script does NOT work reliably**: the change can lose to a sync round-trip and revert. Create here; change or remove recurring series in Calendar.app (right-click, Delete, "Delete All Events in the Series").

## Moving / rescheduling
There is no in-place edit script. To reschedule a **one-off** event: `delete.sh` it, then `add.sh` at the new time. For **recurring** events, do it in Calendar.app, not via script.

## Guardrails
- Writes to a shared/synced calendar can notify other attendees: **confirm before adding or deleting anything on shared or invited events**.
- Never fabricate times; ask for the real time/duration if unspecified.
- Do not script changes to recurring series; recommend the app instead.
- icalBuddy must be installed: `brew install ical-buddy`. The scripts add `/opt/homebrew/bin` (and `/usr/local/bin`) to PATH.
- **Synced calendars have lag.** After `add.sh`/`delete.sh`, wait a few seconds, then re-run `list.sh` to confirm. A delete fired too soon after a create can be undone by a re-sync; if a deleted event reappears, just delete again.
