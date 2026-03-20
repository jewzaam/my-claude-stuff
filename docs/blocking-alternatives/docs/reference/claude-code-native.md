# Claude Code Native Features

Dimension: built-in permissions, deny lists, sandbox configuration, and hook system in Claude Code.

See [../citations.md](../citations.md) for full source details.

---

## Permission System

### Settings Files and Precedence

| Priority | Scope | File | Override? |
|----------|-------|------|-----------|
| 1 (highest) | Managed | Server-managed / MDM / managed-settings.json | Cannot be overridden |
| 2 | CLI | Command line arguments | Per-invocation |
| 3 | Local project | `.claude/settings.local.json` | Not checked in |
| 4 | Project | `.claude/settings.json` | Shared with team |
| 5 (lowest) | User | `~/.claude/settings.json` | Global defaults |

Arrays in `permissions.allow` and `permissions.deny` are concatenated and deduplicated across scopes, not replaced [1].

### Allow/Deny Rule Syntax

Rules follow `Tool` or `Tool(specifier)` format [1]:

| Pattern | Description |
|---------|-------------|
| `Bash(npm run build)` | Exact match |
| `Bash(npm run test:*)` | Prefix match |
| `Bash(npm *)` | Wildcard: any command starting with `npm` |
| `Bash(* install)` | Suffix match |
| `Bash(git * main)` | Interior wildcard |
| `Bash` (no parens) | Matches ALL Bash uses |
| `Read(./.env)` | Block reading specific files |
| `Read(./secrets/**)` | Block reading directory trees |

**Evaluation order:** deny -> ask -> allow. First matching rule wins; deny always takes precedence [1] [2].

**Chain awareness:** Claude Code understands shell operators (`&&`), so `Bash(safe-cmd:*)` will not permit `safe-cmd && other-cmd` [1].

### Built-in Command Blocklist

Claude Code maintains a built-in command blocklist that blocks `curl` and `wget` by default [5]. Additional guardrails include command injection detection and fail-closed matching (unmatched commands default to requiring manual approval) [5].

**Gap:** The full contents of the built-in blocklist are not documented. Only `curl` and `wget` are explicitly named. Whether `sudo`, `rm -rf`, `git push --force`, or similar destructive commands are on the blocklist is undocumented [5].

## Permission Modes

| Mode | Behavior | SDK |
|------|----------|-----|
| `default` | Standard permission checking with user prompts | Both |
| `acceptEdits` | Auto-approves file operations; Bash still prompts | Both |
| `bypassPermissions` | Auto-approves ALL tool uses; hooks/deny rules still apply | Both |
| `plan` | Prevents tool execution entirely; analysis only | Both |
| `dontAsk` | Converts permission prompts to denials | TypeScript only |

In `bypassPermissions` mode: deny rules, explicit ask rules, and hooks are evaluated before the mode check and can still block a tool [2] [6].

## Sandbox Configuration

```json
{
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": true,
    "excludedCommands": ["docker"],
    "filesystem": {
      "allowWrite": ["/tmp/build", "~/.kube"],
      "denyRead": ["~/.aws/credentials"]
    },
    "network": {
      "allowedDomains": ["github.com", "*.npmjs.org"],
      "allowUnixSockets": ["/var/run/docker.sock"],
      "allowLocalBinding": true
    }
  }
}
```

Key properties [1] [39]:
- `sandbox.filesystem` controls OS-level sandbox boundaries
- Restrictions apply to ALL subprocess commands (kubectl, terraform, npm), not just Claude's file tools
- Default: Claude Code can only write to CWD and subdirectories
- `sandbox.network.allowedDomains` restricts outbound network access
- `sandbox.excludedCommands` exempts specific commands from sandboxing

## Hook System

### Event Types

PreToolUse, PostToolUse, PostToolUseFailure, Notification, UserPromptSubmit, SessionStart, SessionEnd, Stop, SubagentStart, SubagentStop, PreCompact, PermissionRequest, Setup, TeammateIdle, TaskCompleted, ConfigChange, WorktreeCreate, WorktreeRemove [3].

### PreToolUse Decision Control

**Exit code approach** [3] [4]:
- Exit 0: action proceeds
- Exit 2: action blocked (stderr sent to Claude as feedback)
- Other: action proceeds, stderr logged

**Structured JSON approach** (exit 0 with JSON on stdout) [4]:
- `permissionDecision: "allow"` — skip permission prompt (deny/ask rules still apply)
- `permissionDecision: "deny"` — cancel tool call
- `permissionDecision: "ask"` — show permission prompt to user

Additional capabilities: `updatedInput` (modify tool input), `additionalContext` (inject context for Claude) [4].

### Execution Details

- Default timeout: 10 minutes (increased from 60 seconds in v2.1.3) [3]
- All matching hooks run in parallel [3]
- Direct edits to hooks in settings files don't take effect immediately (prevents malicious modification of current session) [3]
- Input includes: session_id, transcript_path, cwd, permission_mode, agent_id, agent_type, tool_name, tool_input [3]

## --dangerously-skip-permissions

- Bypasses all permission prompts for fully autonomous operation [6]
- Deny rules and hooks are still evaluated [6]
- Recommended only inside devcontainers with firewall isolation [7]
- Warning: devcontainers don't prevent credential exfiltration [7]

## Comparison to Custom Hooks

| Capability | Native permissions.deny | Custom PreToolUse hooks |
|------------|------------------------|------------------------|
| Pattern matching | Glob-style wildcards | Regex (arbitrary complexity) |
| Path blocking | `sandbox.filesystem.denyRead` (OS-level) | Regex on resolved paths (application-level) |
| Command blocking | `Bash(pattern)` glob matching | Regex with chain splitting, heredoc stripping |
| Chain awareness | Built-in `&&` awareness | Custom parser required |
| Enforcement level | OS-level (sandbox) + application | Application only |
| Escape risk | Agent can use `dangerouslyDisableSandbox` [42] | No agent-accessible escape hatch |
| Cross-platform | macOS + Linux + WSL2 | Any platform with Python |
| Custom logic | None | Arbitrary (logging, context-dependent decisions) |

## Gaps and Limitations

1. Built-in command blocklist contents are undocumented beyond curl/wget [5]
2. `permissions.deny` uses glob patterns, not regex — complex patterns (e.g., `rm\s+-rf\s+/`) cannot be expressed [1]
3. Sandbox has known escape hatch: agent can autonomously use `dangerouslyDisableSandbox` [42]
4. `dontAsk` mode is TypeScript SDK only [2]
5. Sandbox `enableWeakerNestedSandbox` mode "considerably weakens security" [39]
