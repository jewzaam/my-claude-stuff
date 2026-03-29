# Global Memory

## User
- [License preference](user_license.md) — Always Apache 2.0, never MIT
- [Gender neutral language](user_pronouns.md) — Default to they/them, don't assume gender from names
- [User environment](user_environment.md) — Linux/Wayland at work, Windows at home, gwt for worktrees

## Feedback
- [No speculation](feedback_no_speculation.md) — Never state guesses as facts, especially timing or behavioral claims
- [Rigor over shortcuts](feedback_rigor.md) — Never fill gaps with confident-sounding guesses, do the work or say "I don't know"
- [Bash tool quoting](feedback_bash_quoting.md) — Bash tool rejects quoted strings in flags/args, output text directly
- [Don't optimize tokens](feedback_dont_optimize_tokens.md) — Speed over token efficiency, read full content directly
- [Trace downstream impact](feedback_downstream_impact.md) — Grep all consumers of changed interfaces before marking done
- [Always use subagents](feedback_subagent_execution.md) — Never ask subagent vs inline, just use subagent-driven
- [Write tests for new code](feedback_write_new_tests.md) — Write NEW tests for new functionality, don't just run existing
- [Filter resolved PR comments](feedback_resolved_pr_comments.md) — Exclude resolved threads from interactive PR review
- [Check allowlist first](feedback_use_allowlist.md) — Call mcp__allowlist__get_allowed_permissions before ANY tool use to avoid approval prompts
- [.claude/ not for output](feedback_claude_dir_security.md) — .claude/ is config only, never write generated content there
