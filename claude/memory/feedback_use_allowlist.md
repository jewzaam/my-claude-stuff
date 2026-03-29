---
name: Check allowlist before using tools
description: Call mcp__allowlist__get_allowed_permissions before ANY Bash or tool use to avoid approval prompts — user has repeatedly flagged non-compliance
type: feedback
---

Before using ANY tool that might require approval — especially Bash commands — call `mcp__allowlist__get_allowed_permissions` first to check what's already permitted. Use allowlisted commands and tool patterns whenever possible.

**Why:** The user's environment is designed to minimize interactive approval prompts. Every unapproved tool call interrupts their workflow. This has been flagged repeatedly because agents consistently skip the allowlist check despite it being in CLAUDE.md.

**How to apply:**
1. At the start of a session or before your first Bash/tool call, call `mcp__allowlist__get_allowed_permissions`
2. Prefer allowlisted command patterns (e.g., `git log *` is allowed — use it instead of a Bash call that will prompt)
3. Do NOT pipe or chain allowlisted commands with non-allowlisted commands — `git log --oneline | head -5` will trigger approval because the full pipeline is evaluated, not just the first command. Use flags on the allowlisted command itself (e.g., `git log --oneline -5`) or use separate tool calls.
4. When you need a command that isn't allowlisted, check if there's a dedicated tool (Read, Glob, Grep, Edit) that avoids the Bash tool entirely
5. Only fall through to an unapproved Bash call as a last resort
