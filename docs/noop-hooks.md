# No-op Hooks: Why They Exist

## Root Cause

Claude Code does **not** emit an OTEL event for a hook type unless at least one hook of that type is
configured in `settings.json`. The event is simply never written to the telemetry pipeline.

Confirmed for `PermissionRequest`: when no `PermissionRequest` hook exists, the session goes
completely silent at the permission dialog. `tool_decision` only fires *after* the user responds.
Zero telemetry while waiting — and zero telemetry if no hook is defined at all.

This is a Claude Code internal behavior: hook presence gates OTEL event emission. It is not
documented as such; it was discovered by observing that `hook_event="PermissionRequest"` never
appeared in Loki despite the `claude_session_permission` recording rule being logically correct.

## Fix

`claude/settings.json.d/hooks-noop.json` registers a no-op command (`python3 -c ""`) for 31
of the 33 hook event types Claude Code accepts:

- `ConfigChange`
- `CwdChanged`
- `DirectoryAdded`
- `Elicitation`
- `ElicitationResult`
- `InstructionsLoaded`
- `Notification`
- `PermissionDenied`
- `PermissionRequest`
- `PostCompact`
- `PostModelSwitch`
- `PostToolBatch`
- `PostToolUse`
- `PostToolUseFailure`
- `PreCompact`
- `PreModelSwitch`
- `PreToolUse`
- `SessionEnd`
- `SessionStart`
- `Setup`
- `Stop`
- `StopFailure`
- `SubagentStart`
- `SubagentStop`
- `TaskCompleted`
- `TaskCreated`
- `TeammateIdle`
- `UserPromptExpansion`
- `UserPromptSubmit`
- `WorktreeCreate`
- `WorktreeRemove`

The command exits 0 immediately and produces no output. Its only purpose is to satisfy the
presence check so all event types flow through the OTEL pipeline.

## Deliberate Exclusions

Two of the 33 are registered nowhere on purpose:

- `FileChanged` — only fires for paths registered through `watchPaths`, which a hook returns in its
  own output. A no-op returns nothing, so it would never fire. Dead entry.
- `MessageDisplay` — fires once per stream flush of an assistant message (`index` increments per
  flush, `final` marks the last). One `python3` spawn per flush, mid-turn, on every message. The
  telemetry is not worth the added latency.

## Consequence

Any OTEL-based alerting or recording rule that depends on a hook event type **requires** a hook of
that type to exist — even if the hook does nothing. If a new event type is added to Claude Code and
you want to observe it, add it here.

## Cross-Platform Note

`python3 -c ""` is used rather than `true` because Claude Code on Windows may invoke hooks via a
shell where `true` is not available. Python is a project dependency, guaranteed present.
