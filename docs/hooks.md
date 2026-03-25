# Hooks Overview

## TL;DR

This repo uses Claude Code hooks to block destructive commands and log prompts/responses/questions. All hooks are configured in `claude/settings.json` and deployed via `make reconcile`.

## What Are Hooks

Claude Code hooks are shell commands that execute in response to lifecycle events. They receive JSON on stdin describing the event context and can:

- **Exit 0** to allow the event to proceed
- **Exit 2** to block the event (PreToolUse only)
- Write to stdout/stderr for feedback to the user

Configuration lives in `claude/settings.json` under the `hooks` key.

## Hook Events Used

| Event | Script | Purpose |
|-------|--------|---------|
| `PreToolUse` (Bash) | `block_commands.py` | Block destructive commands. See `docs/block-commands-design.md` for details. |
| `PreToolUse` (all) | `block_paths.py` | Block access to sensitive directories (~/.ssh, ~/.aws, ~/.kube, ~/.ocm) and credential files. See `docs/blocked-commands-reference.md` for details. |
| `PostToolUse` (AskUserQuestion) | `prompt_log.py` | Log questions asked and user's answers to JSONL |
| `Stop` | `prompt_log.py` | Log Claude's response to JSONL |
| `UserPromptSubmit` | `prompt_log.py` | Log user's prompt to JSONL |

## Prompt Log Hook (`scripts/prompt_log.py`)

Logs user prompts, Claude responses, and question/answer exchanges as structured JSONL data for session reconstruction.

### Storage Layout

```
~/.claude/prompt-log/
  {YYYY-MM-DD}/
    {session-id}.jsonl
```

### JSONL Schema

Each line contains one of two schemas:

**Prompt/Response entries** (`event_type`: `prompt` or `response`):

| Field | Description |
|-------|-------------|
| `timestamp` | ISO 8601 timestamp (UTC) |
| `event_type` | `prompt` or `response` |
| `session_id` | Claude Code session identifier |
| `working_dir` | Working directory at time of event |
| `git_branch` | Current git branch (empty if not in a repo) |
| `content` | The prompt text or response text |

**Question entries** (`event_type`: `question`):

| Field | Description |
|-------|-------------|
| `timestamp` | ISO 8601 timestamp (UTC) |
| `event_type` | `question` |
| `session_id` | Claude Code session identifier |
| `working_dir` | Working directory at time of event |
| `git_branch` | Current git branch (empty if not in a repo) |
| `question` | The question asked by Claude |
| `options` | Options with label and description (omitted if free-form) |
| `answer` | The user's response |

### Design Decisions

- **No locking needed** -- each session writes to its own file, hooks within a session are sequential
- **Silent failure** -- all exceptions caught; hook never blocks Claude Code
- **Session ID sanitized** -- rejects path separators and special characters
- **Git branch detection** -- 2-second timeout, falls back to empty string
- **No retention policy** -- date-partitioned structure makes manual cleanup trivial

## Block Commands Hook (`scripts/block_commands.py`)

Blocks destructive shell commands before execution. See `docs/block-commands-design.md` for design rationale and `docs/blocked-commands-reference.md` for the full pattern reference.

## Adding New Hooks

1. Create script in `scripts/`
2. Add hook entry to `claude/settings.json` under the appropriate event
3. Add tests in `tests/`
4. Run `make reconcile` to deploy to `~/.claude/`
