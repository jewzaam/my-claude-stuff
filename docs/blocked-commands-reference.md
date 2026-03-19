# Blocked Commands Reference

Complete reference for every blocked pattern in `scripts/block_commands.py`.

## Git Commands

| Command | Platform | Pattern | Destructive Because | Safe Variants (Allowed) | Case |
|---------|----------|---------|---------------------|------------------------|------|
| `git add` | All | `git add\b` | Stages files — user controls staging | None | Sensitive |
| `git push` | All | `git push\b` | Affects remote state | None | Sensitive |
| `git reset` | All | `git reset\b` | Loses staged work, can rewrite history | None (even `--soft` blocked) | Sensitive |
| `git clean` | All | `git clean\b(?!\s+-(n\|--dry-run)\b)` | Deletes untracked files permanently | `git clean -n`, `git clean --dry-run` | Sensitive |
| `git branch` | All | `git branch\s+.*(?:-[dDmMcC]\b\|--delete\b\|--move\b\|--copy\b)` | Deletes/renames/copies branches | `git branch`, `git branch --list`, `-a`, `-r`, `-v`, `--contains` | Sensitive |
| `git stash` | All | `git stash\b(?!\s+(?:list\|show)\b)` | Modifies working tree or drops stashed changes | `git stash list`, `git stash show` | Sensitive |
| `git commit --amend/-a` | All | `git commit\s.*(?:--amend\b\|-[a-zA-Z]*a)` | `--amend` rewrites history, `-a` auto-stages | `git commit -m msg` | Sensitive |
| `git checkout --` | All | `git checkout\s+--\s` | Discards working tree changes permanently | `git checkout branch`, `git checkout -b new` | Sensitive |
| `git restore` | All | `git restore\b(?!.*--staged)` | Discards working tree changes permanently | `git restore --staged` | Sensitive |

## Unix Privilege Escalation

| Command | Platform | Pattern | Destructive Because | Safe Variants (Allowed) | Case |
|---------|----------|---------|---------------------|------------------------|------|
| `sudo` | Unix | `sudo\b` | Runs commands as root | None | Sensitive |
| `su` | Unix | `su` (standalone, not substring) | Switches to root user | None | Sensitive |

## Unix Filesystem

| Command | Platform | Pattern | Destructive Because | Safe Variants (Allowed) | Case |
|---------|----------|---------|---------------------|------------------------|------|
| `rm -r` | Unix | `rm\s+.*(-[a-zA-Z]*[rR]\|--recursive)\b` | Recursively deletes directories | `rm file.txt`, `rm -f file.txt` | Sensitive |
| `find -delete` | Unix | `find\s+.*\s-delete\b` | Deletes files matching criteria without confirmation | `find . -name '*.py'` | Sensitive |
| `chmod 777` | Unix | `chmod\s+.*\b777\b` | World-writable permissions — security vulnerability | `chmod 755`, `chmod +x` | Sensitive |
| `shred` | Unix | `shred\s+` | Overwrites file data to prevent recovery — inherently destructive | None | Sensitive |

## Unix Disk/Device

| Command | Platform | Pattern | Destructive Because | Safe Variants (Allowed) | Case |
|---------|----------|---------|---------------------|------------------------|------|
| `mkfs` | Unix | `mkfs\S*\s+` | Formats disk partitions — destroys all data | None | Sensitive |
| `dd of=/dev/` | Unix | `dd\s+.*\bof=/dev/` | Writes raw data to block devices | `dd if=a of=b` (file-to-file) | Sensitive |

## Windows Filesystem

| Command | Platform | Pattern | Destructive Because | Safe Variants (Allowed) | Case |
|---------|----------|---------|---------------------|------------------------|------|
| `rd/rmdir /s` | Windows | `(?:rd\|rmdir)\b.*\s/[sS]\b` | Recursively deletes directory trees | `rd somedir` (non-recursive) | Insensitive |
| `del/erase /s` | Windows | `(?:del\|erase)\b.*\s/[sS]\b` | Recursively deletes files | `del file.txt` (single file) | Insensitive |
| `cipher /w` | Windows | `cipher{_WFLAGS}\s+/[wW]\b` | Wipes free space — destroys recoverable data | `cipher /e`, `cipher /d` | Insensitive |

## Windows Disk/System

| Command | Platform | Pattern | Destructive Because | Safe Variants (Allowed) | Case |
|---------|----------|---------|---------------------|------------------------|------|
| `format` | Windows | `format\b.*\s[a-zA-Z]:` | Formats disk drives — destroys all data | None | Insensitive |
| `diskpart` | Windows | `diskpart\b` | Interactive disk partitioning — can destroy volumes | None | Insensitive |
| `bcdedit` | Windows | `bcdedit\b` | Modifies boot configuration — can make system unbootable | None | Insensitive |
| `sc delete` | Windows | `sc\s+delete\b` | Permanently deletes Windows services | `sc query`, `sc start`, `sc stop` | Insensitive |
| `reg delete` | Windows | `reg\s+delete\b` | Deletes registry keys — can break system/applications | `reg query` | Insensitive |

## PowerShell

| Command | Platform | Pattern | Destructive Because | Safe Variants (Allowed) | Case |
|---------|----------|---------|---------------------|------------------------|------|
| `Remove-Item -Recurse` | Windows | `Remove-Item\b.*-Recurse\b` | Recursively deletes files/directories | `Remove-Item file.txt` (single) | Insensitive |
| `Format-Volume` | Windows | `Format-Volume\b` | Formats disk volumes — destroys all data | None | Insensitive |
| `Clear-Disk` | Windows | `Clear-Disk\b` | Wipes all data from a disk | None | Insensitive |
| `Remove-Partition` | Windows | `Remove-Partition\b` | Removes disk partitions — destroys volume structure | None | Insensitive |

## Cross-Platform (Presplit)

| Command | Platform | Pattern | Destructive Because | Safe Variants (Allowed) | Case |
|---------|----------|---------|---------------------|------------------------|------|
| `curl\|sh` | All | `(?:curl\|wget)\b.*\|\s*(?:ba)?sh\b` | Executes arbitrary remote code without review | `curl url \| jq .`, `curl url > file` | Sensitive |

## Project-Specific

| Command | Platform | Pattern | Destructive Because | Safe Variants (Allowed) | Case |
|---------|----------|---------|---------------------|------------------------|------|
| `make reconcile` | All | `make\s+reconcile\b` | Deploys scripts to `~/.claude/` — affects live environment | `make test`, `make format` | Sensitive |

## Google Workspace CLI

The `gws` CLI has 15 blocked patterns covering Gmail, Calendar, Chat, Drive, Sheets, Tasks, Keep, Forms, Docs, Slides, Events, and Meet mutations, plus full-service blocks on Workflow and Classroom. See [gws-cli-blocking.md](gws-cli-blocking.md) for the full reference including threat model, access policy, and security analysis.

## Excluded Commands (Not Blocked)

| Command | Why Excluded |
|---------|-------------|
| `Stop-Service` / `Stop-Process` | Reversible, equivalent to `kill` which we don't block |
| `git revert` | Non-destructive (creates new commit) |
| `python -c` / `node -e` | Too broad, breaks legitimate scripting |
| `eval` | Too broad, impossible to regex effectively |
| `dd` (without `of=/dev/`) | Legitimate uses (test files, backups) |
| `mount` / `umount` | Requires sudo which is already blocked |
| `insmod` / `modprobe` | Requires sudo which is already blocked |
| `iptables` / `nftables` | Requires sudo which is already blocked |
| `fdisk` / `parted` | Requires sudo which is already blocked |
| `lvm` commands | Requires sudo which is already blocked |
| `net stop` | Requires admin elevation on Windows |
