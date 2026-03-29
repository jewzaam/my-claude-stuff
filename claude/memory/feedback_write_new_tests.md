---
name: Write tests for new code
description: Write NEW tests for new functionality — don't just run existing tests and call it done
type: feedback
---

When adding new functionality, write new tests that cover it. Running existing tests only validates you didn't break old behavior — it says nothing about whether the new code works.

**Why:** The user called this out when new code was added without corresponding test coverage.

**How to apply:** After writing new functions, classes, or behavior, add tests for them. This applies even when existing tests pass.
