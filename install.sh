#!/usr/bin/env bash
# MapMyVault install — copies the local skill to ~/.claude/skills/ (for development)
# For end users, prefer: clawhub install map-my-vault
# Or: mkdir -p ~/.claude/skills/map-my-vault && curl -fsSL https://raw.githubusercontent.com/wanli6/MapMyVault/main/skills/map-my-vault/SKILL.md -o ~/.claude/skills/map-my-vault/SKILL.md

set -euo pipefail

SKILL_SRC="$(cd "$(dirname "$0")/skills/map-my-vault" && pwd)"
SKILL_DST="$HOME/.claude/skills/map-my-vault"

if [ ! -f "$SKILL_SRC/SKILL.md" ]; then
  echo "ERROR: SKILL.md not found at $SKILL_SRC" >&2
  exit 1
fi

mkdir -p "$SKILL_DST"
cp "$SKILL_SRC/SKILL.md" "$SKILL_DST/SKILL.md"

echo "Installed: $SKILL_DST/SKILL.md"
echo "Restart Claude Code to load the skill, then invoke with: /map-my-vault"
