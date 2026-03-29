---
name: Always use subagent execution
description: Never ask whether to use subagent vs inline execution — just use subagent-driven development
type: feedback
---

When executing implementation plans with independent tasks, use subagent-driven development. Don't ask the user whether to use subagents or do it inline.

**Why:** The user corrected this pattern — asking is unnecessary friction. Subagent execution is the default.

**How to apply:** When you have independent implementation tasks, dispatch subagents. Don't present "should I use subagents?" as a choice.
