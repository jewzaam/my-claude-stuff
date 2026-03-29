---
name: Don't optimize tokens
description: Speed over token efficiency — read full content directly instead of trying to be clever about partial reads
type: feedback
---

Read full file content directly. Don't try to optimize by reading partial files or summarizing to save tokens.

**Why:** Token optimization slows down the workflow and produces worse results. The user pays for tokens and values speed and accuracy over efficiency.

**How to apply:** When you need file content, read the whole thing. Don't use offset/limit unless the file is genuinely too large. Don't summarize intermediate results to save context.
