# Hooks Overview

## TL;DR

This repo uses Claude Code hooks to block destructive commands. Custom hooks are in `claude/settings.json.d/hooks-my-claude-stuff.json`. Additional fragments: `hooks-ai-guardian.json` (security scanning), `hooks-noop.json` (OTEL event coverage). All deployed via `make reconcile`.

## What Are Hooks

Claude Code hooks are shell commands that execute in response to lifecycle events. They receive JSON on stdin describing the event context and can:

- **Exit 0** to allow the event to proceed
- **Exit 2** to block the event (PreToolUse only)
- Write to stdout/stderr for feedback to the user

Configuration lives in `claude/settings.json.d/hooks-my-claude-stuff.json`.

## Hook Events Used

### Custom hooks (`hooks-my-claude-stuff.json`)

| Event | Script | Purpose |
|-------|--------|---------|
| `PreToolUse` (Bash) | `block_commands.py` | Block destructive commands. See `docs/block-commands-design.md` for details. |
| `PreToolUse` (all) | `block_paths.py` | Block access to sensitive directories (~/.ssh, ~/.aws, ~/.kube, ~/.ocm) and credential files. See `docs/blocked-commands-reference.md` for details. |

### Third-party hooks

#### ai-guardian (`hooks-ai-guardian.json`)

[ai-guardian](https://github.com/itdove/ai-guardian) ([PyPI](https://pypi.org/project/ai-guardian/)) scans prompts, tool inputs, and tool outputs for prompt injection and sensitive data leakage.

| Event | Matcher | Purpose |
|-------|---------|---------|
| `PreToolUse` | `*` | Check tool permissions before execution |
| `Notification` | `*` | Scan tool output for injection/leakage |
| `UserPromptSubmit` | `*` | Scan user prompts |

#### hooks-noop (`hooks-noop.json`)

No-op hooks covering every event type. Required so Claude Code emits OTEL data for all events —
presence of a hook gates OTEL emission. See [`docs/noop-hooks.md`](noop-hooks.md) for full
explanation.

## Block Commands Hook (`scripts/block_commands.py`)

Blocks destructive shell commands before execution. See `docs/block-commands-design.md` for design rationale and `docs/blocked-commands-reference.md` for the full pattern reference.

## Adding New Hooks

1. Create script in `scripts/`
2. Add hook entry to `claude/settings.json.d/hooks-my-claude-stuff.json` under the appropriate event
3. Add tests in `tests/`
4. Run `make reconcile` to deploy to `~/.claude/`
