---
name: Trace downstream impact
description: Grep all consumers of changed interfaces before marking work done
type: feedback
---

When changing a function signature, API, config key, or any interface — grep for all consumers and update them before marking the task done.

**Why:** Changing an interface without updating callers causes silent breakage. The user caught this happening and wants it prevented.

**How to apply:** After modifying any interface, grep the codebase for all usages. Update each caller. Don't assume "only this file uses it."
