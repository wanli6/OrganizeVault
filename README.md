# OrganizeVault

A Claude Code skill for organizing Markdown/Obsidian vaults into a topic-based directory structure with MOC (Map of Content) files.

## What it does

- **Initial setup**: scans all note titles, proposes a topic directory structure, moves notes into the right folders, and creates a `MOC.md` in each directory plus a root index
- **Incremental maintenance**: detects new notes via `git status`, moves them to the matching topic directory, and updates the corresponding `MOC.md`

Note content is never modified — only file locations and MOC files change. All changes are git-tracked.

## Install

### Via OpenClaw

```bash
clawhub install organize-vault
```

### Via curl (Claude Code)

```bash
mkdir -p ~/.claude/skills/organize-vault && \
curl -fsSL https://raw.githubusercontent.com/wanli6/OrganizeVault/main/skills/organize-vault/SKILL.md \
  -o ~/.claude/skills/organize-vault/SKILL.md
```

Restart Claude Code after installing. The skill is available as `/organize-vault`.

## Usage

Open Claude Code in your vault directory and run:

```
/organize-vault
```

Or say: "整理一下 vault"、"把新笔记归类"、"初始化 MOC 结构"

Claude will ask for your vault path if needed, show a full preview of every file move and MOC change, and wait for your confirmation before writing anything.

## Requirements

- Claude Code
- Your vault must be a git repository (`git init` if not)

## Uninstall

```bash
rm -rf ~/.claude/skills/organize-vault
```
