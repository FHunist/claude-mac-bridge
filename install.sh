#!/usr/bin/env bash
# Install the claude-mac-bridge skills into ~/.claude/skills/ by symlinking, so a
# later `git pull` updates them in place. Re-runnable. Existing entries are NOT
# clobbered unless you pass --force.
#
# Usage:
#   ./install.sh           # symlink each skill; skip any that already exist
#   ./install.sh --force   # replace existing skills/symlinks of the same name
#
# After installing, restart Claude Code (or start a new session) so it picks up
# the skills, then personalize the CONFIG blocks (see README.md).

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
SRC="$HERE/skills"
DEST="$HOME/.claude/skills"
FORCE="${1:-}"

mkdir -p "$DEST"

for d in "$SRC"/*/; do
  name="$(basename "$d")"
  target="$DEST/$name"
  if [ -e "$target" ] || [ -L "$target" ]; then
    if [ "$FORCE" = "--force" ]; then
      rm -rf "$target"
    else
      echo "skip: $name already exists at $target (use --force to replace)"
      continue
    fi
  fi
  ln -s "$d" "$target"
  echo "linked: $name -> $target"
done

# make sure the helper scripts are executable
chmod +x "$SRC"/*/scripts/*.sh 2>/dev/null || true

echo
echo "Done. Next:"
echo "  1. Install icalBuddy (calendar reads): brew install ical-buddy"
echo "  2. Personalize the CONFIG blocks in the scripts (see README.md)."
echo "  3. Restart Claude Code, then try: /plan-day"
