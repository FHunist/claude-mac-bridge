---
name: agenda-sync
description: Cross-check your calendar against your todos to surface gaps. Deadlines with no time blocked to do them, overdue/at-risk todos, and appointments that have no prep todo. Use to reconcile your plan, catch what is about to slip, or run a weekly review.
---

# Agenda Sync (calendar ↔ todos reconciliation)

Reconciles two sources you already have: Apple **Reminders** ([[todos]]) and Apple **Calendar** ([[calendar]]). The point is to catch the gaps between intention (todos) and schedule (calendar). **Analysis is read-only; it only writes (blocks / prep todos) after you approve.** Mac-only. Requires the [[calendar]] and [[todos]] skills installed alongside it.

## On invocation
1. **Anchor to now.** Run `date "+%A %Y-%m-%d %H:%M %Z"`. All "overdue / imminent" judgments key off this.
2. **Pull both sources:**
   - Todos: `bash ~/.claude/skills/todos/scripts/list.sh` (slow, 30 to 60s; lines are `LIST ||| TITLE ||| DUE ||| PRIORITY`).
   - Calendar: `bash ~/.claude/skills/calendar/scripts/list.sh 14` (today to +14 days; widen for far-off deadlines).
3. **Compute the gaps**, which is the whole point:
   - 🔴 **Deadline, no block**: a todo with a due date but no calendar time set aside to actually do it before then (e.g. a deliverable due Thursday 3pm with nothing blocked to prepare it). The nearer the due date and the bigger the task, the louder the flag.
   - ⏰ **Overdue / at-risk**: due date already passed, or imminent with no progress block. Surface long-lead items (anything with a notice period or external dependency) early.
   - 📋 **Event, no prep**: a meeting/appointment that clearly needs preparation but has no matching prep todo (advisor/manager 1:1s, presentations, admin or medical appointments).
   - 🧭 **Lead-time mismatch**: a deadline whose external lead time (notice periods, shipping, doc-gathering) is longer than the time remaining.
4. **Present a short reconciliation**, grouped by the four buckets above. Each line names the specific todo/event and the concrete fix. Do not restate the full calendar or todo list; only the gaps.
5. **Offer the fixes, act on approval:**
   - Block time for a deadline: `calendar/scripts/add.sh "" "<task> prep" "YYYY-MM-DD HH:MM" <min>`.
   - Add a prep/buffer todo: `todos/scripts/add.sh "<list>" "<prep task>" YYYY-MM-DD <priority>`.
   - Add a due date to a dateless-but-deadlined todo (back-calculated, never fabricated; confirm the real deadline first).
   Confirm before bulk changes; one or two obvious fixes can be proposed and applied on a "yes".

## Good cadence
Works well as a **weekly review** (e.g. Friday, alongside a next-week calendar preview) or any time the plan feels out of sync. Can be looped: `/loop /agenda-sync` (self-paced), but it is most useful on demand, not on a tight timer.

## Guardrails
- Read-only until you approve a write. Never silently add or move things.
- Never fabricate a due date or a meeting time; ask for the real deadline.
- Mailing-list / recurring social events do not need prep todos; do not flag them.
- The todos `list.sh` is slow and may background: read its output when it completes.
