---
name: fix
description: Run make and fix issues, optionally in a submodule
allowed-tools: Bash, Read, Edit, Glob, Grep
---

# Fix Skill

## Purpose

Run `make` to validate code and automatically fix any issues found. Supports working in submodules.

## Process

1. **Determine working directory:**
   - If no arguments: work in current directory
   - If argument provided: check if it's a submodule directory and cd into it

2. **Run make:**
   - Assumes `make` runs all check targets
   - If make doesn't exist or doesn't run checks, find and run check targets
   - Common check targets: `format`, `lint`, `coverage`, `test`, `test-unit`, `typecheck`

3. **Fix issues:**
   - Parse error output from make
   - Identify files and issues
   - Use Read tool to examine code
   - Use Edit tool to fix issues
   - Re-run make to verify

4. **Iterate until clean:**
   - Keep running make and fixing issues
   - Stop when make completes successfully

## Critical Rules

- **NEVER run git commands** - no add, commit, push, pull, etc.
- **Fix code only** - make changes to source files and tests
- **Verify fixes** - always re-run make after changes
- **Read before editing** - always read files before making changes
