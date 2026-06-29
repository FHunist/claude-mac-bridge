---
name: plan-day
description: One morning briefing that ties together your calendar, mail, and todos into a single organized plan for today. Read-only synthesis; only writes (blocks, flags, todos) after you approve.
---

# Plan My Day (morning briefing)

The single command that ties together [[calendar]], [[mail]], [[todos]], and the gap-logic from [[agenda-sync]] into one organized plan for today. **Read-only synthesis**: it only writes (blocks, flags, todos) after you approve. Mac-only (Apple Mail/Calendar/Reminders live on the Mac). Requires the [[calendar]], [[mail]], and [[todos]] skills installed alongside it.

## Routine (run in this order)
1. **Anchor to now.** `date "+%A %Y-%m-%d %H:%M %Z"`: ground truth for the timeline and what is already past.
2. **Kick off the slow todos pull first** so it runs while you do the fast reads (it takes 30 to 60s and may background):
   `bash ~/.claude/skills/todos/scripts/list.sh`
3. **Today's calendar.** `bash ~/.claude/skills/calendar/scripts/list.sh 0`: build the timeline; dedupe duplicate-calendar entries; mark past vs ahead; note locations and any conflicts.
4. **Mail triage.** `bash ~/.claude/skills/mail/scripts/list.sh` (default account; widen with another account name if asked). Classify into 🔴 Action / 🟠 FYI / ⚪️ Noise; keep only the Action items for the plan. Also tag which messages arrived **overnight** (since roughly 21:00 the previous evening, using the timestamps + the anchor time) for the overnight overview.
5. **Todos for today.** From the todos output, select: due **today**, **overdue**, **high-priority (1)**, and anything tied to a today event. Ignore someday/low items unless asked.

## Output: one organized plan
Present it as a tight briefing, not three raw dumps:

- **🌙 Overnight**: a 1 to 2 line recap of what landed overnight: a count of new mail, who/what stands out (a real person, anything actionable), and an explicit "nothing urgent" if so. This is the first thing read.
- **📅 Today's timeline**: events in order with times/locations, the next imminent thing called out, conflicts flagged.
- **🕳 Open gaps**: each free block with length, and a concrete suggestion to fill it (deep work, the day's top todo, prep for the next meeting). Respect travel time between locations.
- **✅ Top priorities (ranked)**: merge deadlines-due-today + action mail + prep needs into a short ranked list (3 to 5 items).
- **📬 Needs a reply**: the Action emails: who + what they want.
- **🎯 Start here**: the single best first move given the current time.

## Then offer to act (on approval only)
- Block a gap: `calendar/scripts/add.sh "" "<task>" "YYYY-MM-DD HH:MM" <min>`
- Flag an action email: `mail/scripts/flag.sh "<account>" "<subject>" on red`
- Add / date a todo: `todos/scripts/add.sh` / `set-due.sh`
Propose one or two obvious moves; confirm before anything bulk.

## Cadence
Run it in the **morning** (or whenever you sit down). Can be wrapped in `/loop`, but it is really a once-a-morning command, not a ticker. Pairs with [[agenda-sync]] for a deeper weekly (Friday) review.

## Guardrails
- Read-only until you approve a write; never silently add/move/flag.
- The todos `list.sh` is slow and may background: read its output file when it completes before finalizing the plan.
- Do not fabricate times or deadlines; surface noise as a count, never itemize newsletters.
