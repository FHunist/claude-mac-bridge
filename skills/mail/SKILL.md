---
name: mail
description: Triage your Apple Mail from a Mac. Pull recent messages, classify them, and flag the ones that need action. Use to check email, see what needs a reply, or run a recurring inbox triage (wrap in /loop).
---

# Mail (Apple Mail triage)

Reads and flags Apple Mail through AppleScript helper scripts in `scripts/`. Mail.app aggregates **all** your accounts in one place, so this works across every account you have configured there. Mac-only. **Read + flag only: it never sends, deletes, archives, or marks read.**

> **Personalize first:** set `DEFAULT_ACCOUNTS` at the top of `scripts/list.sh` to your Mail.app account name(s). Use the exact "Description" shown under Mail > Settings > Accounts (e.g. `iCloud`, `Gmail`, `Work`). Account names like `Work` below are placeholders.

## On invocation (triage routine)
1. **Pull recent mail.** `bash ~/.claude/skills/mail/scripts/list.sh` (default account, 10 most recent). For a wider sweep pass an account name: `list.sh Work`, `list.sh iCloud`. Output marks `[UNREAD]` vs `[read]`.
2. **Classify** each unread/recent message into:
   - 🔴 **Action**: needs a reply or a task (a real person asking something, admin with a deadline, bills, anything time-sensitive).
   - 🟠 **FYI**: informational, worth knowing, no action (announcements, receipts).
   - ⚪️ **Noise**: mailing lists and newsletters. Summarize as a count, do not itemize.
3. **Flag the Action items** (reversible): `bash ~/.claude/skills/mail/scripts/flag.sh "<account>" "<subject substring>" on red`. Use red for must-do, orange for a softer "should reply". Unflag with `... off`.
4. **Present a tight triage**, not a dump: a 🔴 Action list (sender + what they want + suggested next step), a short 🟠 FYI list, and "+N list-serv/newsletter items skipped". End with the single most important thing to handle, and offer to draft a reply (draft only, see guardrails).

## Recurring use
Wrap the routine in a loop: **`/loop 45m /mail`** (runs while the Mac and a session are on). Each pass re-triages and flags new Action mail. Flags show up in Mail.app's Flagged smart mailbox and sync to iPhone.

## Scripts
- `list.sh [account] [count]`: fast bulk read (avoids the slow unified-inbox count); resilient inbox resolver. Default account set is editable at the top of the script (`DEFAULT_ACCOUNTS`).
- `flag.sh "<account>" "<subject substring>" [on|off] [color]`: flag/unflag the first matching message (within the 40 most recent). Colors: red orange yellow green blue purple grey.

## Guardrails
- **Read + flag only.** Drafting a reply is fine (tell the user, or use a Gmail connector's `create_draft` if available), but **never auto-send, delete, archive, or mark-read** without explicit say-so.
- Do not flag mailing-list/newsletter noise as Action.
- Account names must match Mail.app exactly, including punctuation (e.g. an account literally named `Yahoo!` needs the `!`).
- Mail's unified-inbox `count` is very slow: always read per-account with the bounded slice (the scripts already do this). Do not iterate the unified `inbox`.
