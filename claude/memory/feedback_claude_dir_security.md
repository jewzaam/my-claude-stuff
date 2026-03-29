---
name: .claude/ is not for generated output
description: Never write generated docs, research, or output files into .claude/ — it's for config only
type: feedback
---

The `.claude/` directory is for configuration (settings.json, CLAUDE.md, skills, hooks). Never write generated content there — research output, documentation, reports, etc.

**Why:** Security concern flagged by the user. Generated content in .claude/ could be picked up by skills or hooks, creating unintended behavior.

**How to apply:** Write generated output to the project directory or a user-specified location. Never target .claude/ for anything except config.
