---
name: Bash tool quoting
description: Bash tool rejects quoted strings in flag names/arguments — remove unnecessary quotes, output text directly
type: feedback
---

The Bash tool rejects commands with quoted strings in flag names/arguments. Never use `echo "text"`, `"--flag"`, or quoted separators like `echo "---"`.

**Why:** The Bash tool's parsing chokes on these patterns. Commands get rejected silently or produce errors.

**How to apply:** Remove all unnecessary quotes from Bash commands. Output text directly instead of using echo. Use heredocs for multi-line content.
