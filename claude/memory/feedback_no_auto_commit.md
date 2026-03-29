---
name: Never auto-invoke commit skill
description: The /commit skill must only run when the user explicitly types /commit — never invoke it automatically after fixes, checks, or any other skill
type: feedback
---

Never invoke the /commit skill unless the user themselves typed `/commit` as their own chat message with the leading slash. No exceptions.

"Explicit user request" means: the user typed `/commit` in chat as their input. It does NOT mean:
- The user said "commit this" or "go ahead and commit" in prose — that is NOT a /commit invocation
- The user said "fine", "ok", "sure", "yes", "proceed", or any other affirmation — that is acknowledgment, NOT a commit request
- Another skill finished and committing seems like a logical next step
- Checks passed and the code looks ready
- The assistant decides it would be helpful
- Any interpretation of user intent that isn't the literal string `/commit`

**Why:** The user was burned by the commit skill being triggered automatically after a /fix run. Committing is an explicit, deliberate decision — never assume the user wants to commit just because checks pass or code was fixed.

**How to apply:** After completing any skill (/fix, /simplify, etc.) or any code changes, STOP. Do not invoke /commit. Do not suggest invoking /commit. The user will type `/commit` themselves when they are ready.
