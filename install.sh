#!/usr/bin/env bash
# OrganizeVault install — copies the local skill to ~/.claude/skills/ (for development)
# For end users, prefer: clawhub install organize-vault
# Or: mkdir -p ~/.claude/skills/organize-vault && curl -fsSL https://raw.githubusercontent.com/wanli6/OrganizeVault/main/skills/organize-vault/SKILL.md -o ~/.claude/skills/organize-vault/SKILL.md

set -euo pipefail

SKILL_SRC="$(cd "$(dirname "$0")/skills/organize-vault" && pwd)"
SKILL_DST="$HOME/.claude/skills/organize-vault"

if [ ! -f "$SKILL_SRC/SKILL.md" ]; then
  echo "ERROR: SKILL.md not found at $SKILL_SRC" >&2
  exit 1
fi

mkdir -p "$SKILL_DST"
cp "$SKILL_SRC/SKILL.md" "$SKILL_DST/SKILL.md"

echo "Installed: $SKILL_DST/SKILL.md"
echo "Restart Claude Code to load the skill, then invoke with: /organize-vault"
