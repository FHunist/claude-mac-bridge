# claude-mac-bridge

A small set of [Claude Code](https://claude.com/claude-code) **skills** that let Claude read and manage your **Apple Calendar, Apple Mail, and Apple Reminders** from a Mac, through native AppleScript and `icalBuddy`. No cloud connectors, no third-party services: everything runs locally against the apps you already use.

The idea: your Google / Exchange / iCloud accounts already sync into Calendar.app, Mail.app, and Reminders.app. These skills give Claude a safe, scriptable bridge to them, so you can ask it to plan your day, triage your inbox, or reconcile your todos against your schedule.

```
you: /plan-day
claude: 🌙 Overnight  | 4 new mails, one from your advisor needs a reply
        📅 Today      | 10:00 standup -> 14:00 1:1 (Bldg 4) -> 17:00 gym
        🕳 Gaps       | 11:00-13:30 free (2.5h) -> suggest: finish the draft
        ✅ Priorities | 1) reply to advisor, 2) submit form, 3) draft slides
        🎯 Start here | reply to the advisor while it is quiet
```

> [!WARNING]
> **Read this before installing.**
>
> **It is vibe-coded.** This was built fast and iteratively with an LLM. It is not formally tested, reviewed, or audited. Read the scripts yourself before you trust them; they are short on purpose.
>
> **It can touch everything on your machine.** These skills run inside Claude Code, which can read and modify files and run shell commands on your Mac, and they hand the assistant a working path into your calendar, mail, and reminders. The scripts run locally and do not send your data anywhere themselves, but anything Claude reads through them (mail, events, reminders) becomes conversation context and is sent to **Anthropic's servers** for the model to process, just like everything else in a Claude Code session. Only install this if you are comfortable letting an LLM read your data and act on your machine on your behalf.

## What's in the box

| Skill | What it does |
|-------|--------------|
| **calendar** | Read your schedule, find free slots, add/delete events (incl. recurring). Reads via `icalBuddy`, writes via AppleScript. |
| **mail** | Triage your inbox: pull recent mail, classify Action / FYI / Noise, and flag what needs a reply. **Read + flag only.** |
| **todos** | List, add, complete, and re-date Apple Reminders. Prioritizes by due date, priority, and lead time. |
| **agenda-sync** | Cross-check calendar against todos to surface gaps: deadlines with no time blocked, overdue items, appointments with no prep. |
| **plan-day** | One morning briefing that ties calendar + mail + todos into a single ranked plan for today. |

`agenda-sync` and `plan-day` orchestrate the other three, so install all of them together.

## Requirements

- **macOS** with Calendar.app, Mail.app, and Reminders.app set up with your accounts.
- **[Claude Code](https://claude.com/claude-code)** (these are skills it loads from `~/.claude/skills/`).
- **icalBuddy** for fast calendar reads: `brew install ical-buddy`.

## Install

```bash
git clone https://github.com/FHunist/claude-mac-bridge.git
cd claude-mac-bridge
./install.sh          # symlinks each skill into ~/.claude/skills/
brew install ical-buddy
```

`install.sh` symlinks the skills so a later `git pull` updates them in place. It will not overwrite an existing skill of the same name unless you pass `--force`. Prefer copies? Just `cp -R skills/* ~/.claude/skills/` instead.

Restart Claude Code (or start a new session) so it picks up the skills.

## Personalize

The scripts ship with placeholder defaults. Two small edits make them yours:

1. **Mail account(s):** in `skills/mail/scripts/list.sh`, set `DEFAULT_ACCOUNTS` to the account name(s) exactly as shown in **Mail > Settings > Accounts** (the "Description" field), e.g. `("Work" "iCloud")`.
2. **Default calendar:** in `skills/calendar/scripts/add.sh`, set `DEFAULT_CAL` to the calendar you write to most.

Reminders and the calendar/mail commands take the list/calendar/account name as an argument, so use whatever names appear in the apps' sidebars. The skill files (`SKILL.md`) are written generically; you can tailor the routines to your own lists and habits.

## Permissions (one-time)

The first time Claude runs a script, macOS will ask the terminal app to control Calendar / Mail / Reminders. Click **Allow** (or grant it under **System Settings > Privacy & Security > Automation**). If a script silently returns nothing, an Automation permission is usually the cause.

## Safety model

These skills are deliberately conservative:

- **Mail is read + flag only.** It never sends, deletes, archives, or marks messages read.
- **Calendar and todos confirm before destructive or shared writes.** The skill instructions tell Claude to ask before deleting, before touching shared/invited events, and before bulk edits.
- **The scripts are local; the conversation is not.** The skill scripts have no API keys and make no network calls of their own beyond what the Apple apps already do to sync. But whatever Claude reads through them becomes Claude Code conversation context and is sent to **Anthropic's servers** for the model to process, like any other prompt.

Read each `SKILL.md` before installing; it is the exact instruction set Claude follows.

## Notes & gotchas

- **Synced calendars have lag.** After a write, wait a few seconds and re-read to confirm. A delete fired immediately after a create can be undone by a sync round-trip.
- **Recurring events** are only reliable on iCloud calendars; Google-synced calendars may drop the recurrence rule. Edit existing series in Calendar.app, not via script.
- **Reminders' AppleScript bridge is slow** (30 to 60s for a full list). The todos skill accounts for this and may run the read in the background.

## License

MIT. See [LICENSE](LICENSE).
