---
name: reconcile
description: This skill should be used when the user asks to "reconcile configs", "sync claude settings", "update config repo", or mentions syncing system and repository configurations
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
version: 1.0.0
---

# Reconcile Skill

Bi-directional synchronization of Claude Code configuration between system (`~/.claude/`) and this repository.

## What Gets Tracked

**Global Settings:** `CLAUDE.md`, `settings.json`
**Global Skills:** `skills/<name>/SKILL.md` or `skills/<name>.md`
**Global Agents:** `agent*.json`, `agent*.yaml` (if they exist)

**Ignored:** Runtime data (projects, session-env, tasks, todos, plans, history, cache, plugins, MCP configs)s

## Process

1. **Find repository path:**
   - Check current directory, then ~/source/my-claude-stuff
   - Parse arguments: `--dry-run`, `--direction <system|repo>`, `--category <config|skills|agents>`

2. **Scan and compare files:**
   - System: `~/.claude/CLAUDE.md`, `~/.claude/settings.json`, `find ~/.claude/skills -name "*.md"`
   - Repo: `find claude -name "*.md" -o -name "*.json"`
   - Compare using `diff` with normalized whitespace
   - Validate JSON files using `jq .`
   - Detect status: identical, different, system-only, repo-only, invalid-json

3. **Generate diff report:**
   - Summary: count of identical, different, system-only, repo-only files
   - Issues: JSON errors, naming issues (skill.md vs SKILL.md)
   - Detailed diffs: show `diff -u` for each non-identical file
   - File sizes and line counts

4. **Interactive sync** (default mode):
   For each non-identical file, present options:
   - **Different files:** [S]ystem→repo, [R]epo→system, [D]iff, [K]ip, [Q]uit
   - **System-only:** [A]dd to repo, [K]ip, [Q]uit
   - **Repo-only:** [I]nstall to system, [K]ip, [Q]uit
   - **Invalid JSON:** Show errors, skip (cannot sync to system)

5. **Batch sync** (with `--direction`):
   - `--direction repo`: Copy all system files to repo (safer)
   - `--direction system`: Copy all repo files to system (requires confirmation)
   - Skip invalid JSON when syncing to system

6. **Execute sync:**
   - Validate JSON before copying to system: `jq . file.json`
   - Create directories: `mkdir -p $(dirname target)`
   - Copy files: `cp -v source target`
   - Fix naming: rename `skill.md` to `SKILL.md` in repo

7. **Post-sync:**
   - Run `git status --short` in repo
   - Show modified files
   - Remind user to review and commit:
     ```
     Repository changes detected. Next steps:
     1. Review: git diff
     2. Stage: git add claude/
     3. Commit: /commit
     ```

## Comparison Logic

**JSON files:**
```bash
# Validate
jq . file.json >/dev/null 2>&1 || echo "invalid-json"

# Compare normalized
diff -q <(jq -S . file1.json) <(jq -S . file2.json)
```

**Text files:**
```bash
# Normalize whitespace and compare
diff -q <(sed 's/[[:space:]]*$//' file1) <(sed 's/[[:space:]]*$//' file2)
```

## File Mapping

**System → Repo:**
- `~/.claude/CLAUDE.md` → `claude/CLAUDE.md`
- `~/.claude/settings.json` → `claude/settings.json`
- `~/.claude/skills/commit/SKILL.md` → `claude/skills/commit/SKILL.md`
- `~/.claude/skills/github:review-list.md` → `claude/skills/github:review-list.md`

**Naming fixes:**
- Detect `skill.md` (lowercase) in repo directories
- Offer to rename to `SKILL.md` (uppercase)
- Auto-fix during sync to repo

## Critical Safety Rules

- **NEVER run `git add` or `git commit`** - only read-only git commands
- **NEVER push changes** - user does this explicitly
- **Validate JSON** before syncing to system (refuse if invalid)
- **Always confirm** before overwriting system files
- **Warn user** when syncing repo → system
- **Remind user** to review and commit manually

## Self-Update

When invoked with `--update-skill`:
- Read this skill file
- Check if new patterns should be tracked
- Generate updated content with new patterns
- Show diff of changes
- Ask user approval
- Write to skill file and increment version

## Usage Examples

```bash
/reconcile                          # Interactive: show diff, prompt for each file
/reconcile --dry-run                # Show diff only, no sync
/reconcile --direction repo         # Sync all system → repo
/reconcile --direction system       # Sync all repo → system (with confirmations)
/reconcile --category skills        # Sync only skills category
```

## Notes

- Local skill specific to this repository (not global)
- Can be run from any directory (auto-finds repo)
- Standardizes skill naming to SKILL.md
- Handles JSON validation before system sync
- Reports git status after changes
- User must manually commit (skill never runs git add/commit)
