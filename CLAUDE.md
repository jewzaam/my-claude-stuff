# Project Rules

## Overview

Claude Code configuration management repo. The `claude/` directory is the source-of-truth for global Claude Code config (`CLAUDE.md`, `settings.json`). The `scripts/` directory contains hook scripts and utilities that get deployed to `~/.claude/`.

## Key Commands

- `make check` — run all checks (format, lint, typecheck, test, coverage)
- `make test` — run pytest only
- `make format` — format code with black + sort settings.json

## Architecture

- `scripts/` — Python hook scripts and utilities (the main code)
- `claude/` — source-of-truth config deployed to `~/.claude/` via `make reconcile`
- `claude/settings.json` — global Claude Code settings (hooks, permissions)
- `tests/` — pytest tests with conftest.py guards that block writes to real `~/.claude/`

## Restricted Operations

- **`make reconcile` is USER ONLY** — never run it. It deploys scripts and config to `~/.claude/` which affects the live Claude Code environment. Only the user decides when to deploy.
