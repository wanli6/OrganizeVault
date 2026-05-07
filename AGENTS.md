# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## Project Overview

**OrganizeVault** is a knowledge base organization assistant — a tool to help personal note collections (e.g. Obsidian vaults) become more navigable, trustworthy, and maintainable over time.

The project is currently in the **design phase**. There is no source code yet. The sole artifact is `doc/design.md` (written in Chinese), which defines the product vision, philosophy, and design principles.

The final product may be delivered as an Obsidian plugin, a Codex skill, or a combination of both.

## Design Constraints (binding on all implementations)

These principles from `doc/design.md` must be respected in any implementation:

1. **Never modify note content without consent.** The system may observe, move, and link notes, but must not rewrite, normalize, or append content to a note's interior. This is the trust boundary.
2. **Suggest, don't automate.** Every meaningful action should be reviewable before it executes. Prefer explicit suggestions over hidden automation.
3. **Keep human judgment in meaningful decisions.** Naming a category, resolving ambiguous placement, deciding if structure "feels right" — these remain user decisions.
4. **Maps over archives.** Topic maps are the primary navigation interface. Structure should be visible and auditable, not buried in folder hierarchies.
5. **Treat ambiguity as normal.** Notes that don't fit neatly are valid data, not failures to be forced into categories.
6. **Prefer reversible changes.** Users must be able to review, reject, or roll back any structural change.
7. **Progressive ordering.** Distinguish initial organization (first map) from ongoing maintenance (keeping the map current). Don't try to produce perfect structure in one pass.
8. **Let the vault evolve.** Don't lock in final structure prematurely; allow reorganization as the user's thinking evolves.

## Installation

To install the skill so Codex can discover and invoke it:

```bash
./install.sh
```

This copies `skills/organize-vault/SKILL.md` to `~/.Codex/skills/organize-vault/SKILL.md`. Restart Codex after installing. The skill then becomes available as `/organize-vault`.

To uninstall:
```bash
rm -rf ~/.Codex/skills/organize-vault
```

## Skill: organize-vault

The core deliverable is `skills/organize-vault/SKILL.md` — a Codex skill that runs entirely via file system operations and Codex's own reasoning. No external dependencies, no separate runtime.

**Invoke**: `/organize-vault`, or ask Codex to "整理 vault"、"归类新笔记"、"初始化 MOC".

**What it does**:
1. Uses `git status` to find new `.md` files since the last commit
2. Reads existing MOC files to understand the current topic structure
3. Reads each new note's full content, then decides which MOC(s) it belongs to
4. Shows a preview of all changes before writing anything
5. Appends `[[wikilinks]]` to the appropriate MOC files after user confirmation

**Two modes**:
- **Incremental** (MOC files already exist): adds new notes to existing MOCs
- **Initialize** (no MOC files yet): proposes a topic structure from note titles, then populates MOC files in batches

**Rollback**: all changes are git-tracked; `git revert` is the only rollback mechanism needed.

**MOC file convention**: files named with `MOC`, `Index`, `Map`, `_index`, or located in `maps/`, `moc/`, `indexes/` directories are treated as MOC files and excluded from categorization targets.

## Architecture

The system is intentionally minimal:
- `skills/organize-vault/SKILL.md`: the skill definition — describes the full workflow for Codex
- `install.sh`: copies the skill to `~/.Codex/skills/` so Codex can discover it
- No code library, no MCP server, no embedding model
- Codex does all reasoning; standard file tools (Read, Write, Edit, Bash) do the I/O
- The vault's git history is the state store and rollback mechanism
