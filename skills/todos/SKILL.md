---
name: todos
description: Pull, triage, prioritize, and manage your Apple Reminders from a Mac. Use to see your todos, decide what to work on next, add a reminder, or mark one done.
---

# Todos (Apple Reminders)

Reads and writes Apple Reminders through the AppleScript helper scripts in this skill's `scripts/` dir. Mac-only (Reminders syncs to the Mac via iCloud). Apple Reminders has no cloud connector, so this is the bridge.

> **Personalize first:** these scripts take a list name as their first argument. Use the exact list names from Reminders.app's sidebar (e.g. `Reminders`, `Work`, `Groceries`). List names like `Work` below are placeholders.

## On invocation
1. Load all open reminders:
   `bash ~/.claude/skills/todos/scripts/list.sh`
   Reminders' AppleScript bridge is slow: this can take 30 to 60 seconds and may run in the background; if so, read the output file when it completes. Output lines are `LIST ||| TITLE ||| DUE ||| PRIORITY` (priority: 0 none, 1 high, 5 medium, 9 low; empty DUE means no due date).
2. Present them **grouped and prioritized, never a raw dump**: cluster by theme/list, sort by due date, and explicitly flag *overdue* and *no-due-date* items.
3. Then **help the user act**: recommend the single best next thing and break it into a concrete first step. For "what should I do today?", choose by due date + priority + lead time (how long the task takes to clear externally).

## Adding a reminder
`bash ~/.claude/skills/todos/scripts/add.sh "<list>" "<title>" [YYYY-MM-DD] [priority]`
- priority: 0 none, 1 high, 5 medium, 9 low. Due date optional (defaults to 09:00 that day).
- Example: `add.sh "Work" "Send invoice" 2026-07-01 1`

## Changing an existing reminder's due date / time
`bash ~/.claude/skills/todos/scripts/set-due.sh "<list>" "<title substring>" "YYYY-MM-DD[ HH:MM]" [priority]`
- Edits the first OPEN matching reminder **in place** (no recreate). Supports a **time of day**: use this whenever a deadline has a specific time (e.g. "by 3pm"). Time defaults to 09:00; uses the Mac's local timezone.
- `add.sh` cannot set a time (always 09:00) and has no edit mode, so for "give X a 3pm due date" or "move X to next week", prefer `set-due.sh` over complete+re-add.
- Example: `set-due.sh "Work" "Quarterly report" "2026-06-24 15:00" 1`

## Completing a reminder
`bash ~/.claude/skills/todos/scripts/complete.sh "<list>" "<title substring>"`
- Marks the first OPEN reminder in that list whose name contains the substring; echoes what it completed (or "no match").

## Guardrails
- Confirm before bulk edits (adding many due dates, moving items between lists).
- Never fabricate due dates; ask for the real deadline.
- If `list.sh` ever feels too slow, a faster backend is `reminders-cli` (`brew install keith/formulae/reminders-cli`); offer it but do not require it.
