---
name: Never present resolved PR comments
description: Filter out resolved threads before interactive PR review — walking through them wastes time
type: feedback
---

When reviewing PR comments interactively, filter out resolved threads before presenting them to the user.

**Why:** Resolved comments are done. Walking the user through them wastes time and creates noise.

**How to apply:** When fetching PR review comments via gh api, check the resolved/outdated status and exclude resolved threads from the review walkthrough.
