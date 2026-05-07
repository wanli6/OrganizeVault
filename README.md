# OrganizeVault

A Claude Code skill for maintaining MOC (Map of Content) structure in Markdown/Obsidian vaults.

## What it does

- **Incremental maintenance**: detects new notes via `git status`, reads existing MOC files, suggests where each note belongs, and appends `[[wikilinks]]` after your confirmation
- **Initial setup**: when no MOC files exist, scans all note titles, proposes a topic structure, then populates MOC files in batches

It only appends links to MOC files — note content is never touched.

## Install

```bash
git clone https://github.com/wanli6/OrganizeVault.git
cd OrganizeVault
./install.sh
```

Restart Claude Code. The skill is now available as `/organize-vault`.

## Usage

Open Claude Code in your vault directory and run:

```
/organize-vault
```

Or say: "整理一下 vault"、"把新笔记归类"、"初始化 MOC 结构"

Claude will ask for your vault path if needed, show a preview of every change, and wait for confirmation before writing anything. All changes are git-tracked and can be reverted with `git revert`.

## Requirements

- Claude Code
- Your vault must be a git repository (`git init` if not)

## Uninstall

```bash
rm -rf ~/.claude/skills/organize-vault
```
