# Project Rules

## Overview

Claude Code configuration management repo. The `claude/` directory is the source-of-truth for global Claude Code config (`CLAUDE.md`, `settings.json.d/`). The `scripts/` directory contains hook scripts and utilities that get deployed to `~/.claude/`.

## Key Commands

- `make check` — run all checks (format, lint, typecheck, test, coverage)
- `make test` — run pytest only
- `make format` — format code with black + sort settings.json.d/*.json

## Architecture

- `scripts/` — Python hook scripts and utilities (the main code)
- `harness_guards/` — the PreToolUse guards, and **the only thing this repo
  installs**: `pyproject.toml` ships this package and not `scripts/`.
  my-codex-stuff depends on the distribution rather than copying the files, so
  both harnesses run one definition. Hooks invoke it as
  `python3 -m harness_guards.block_commands`, never by path — which means a
  rename or a bad module name fails as exit 1 (a hook error, not a block) and
  the guard silently stops guarding. `tests/test_settings_fragments.py` runs
  each registered module through `-m` for that reason.
- `claude/` — source-of-truth config deployed to `~/.claude/` via `make reconcile`
- `claude/settings.json.d/` — global Claude Code settings fragments (hooks, permissions, plugins)
- `claude/managed-settings.json` — Claude Code managed settings. Holds `deniedModels` (family aliases); there is no `availableModels` allowlist. Installed to `/etc/claude-code/managed-settings.json` by `make deny-anthropic-models`, never by `make reconcile` — whether to block models is a per-machine decision. The target validates with `jq -e '.deniedModels | length > 0'` before sudo, skips the write when `cmp` shows the installed copy matches, then runs `sudo install -Dm644`. `make allow-anthropic-models` removes the file.
- `deniedModels` is honored only from managed settings — it is ignored, with a warning, in user, project, local, and `--settings` files. Requires Claude Code v2.1.283+. Without an `availableModels` allowlist every non-denied model stays selectable, so the denylist is the only block.
- `tests/` — pytest tests with conftest.py guards that block writes to real `~/.claude/`

## Restricted Operations

- **`make reconcile` is USER ONLY** — never run it. It deploys scripts and config to `~/.claude/` which affects the live Claude Code environment. Only the user decides when to deploy.
- **`make deny-anthropic-models` and `make allow-anthropic-models` are USER ONLY** — both edit `/etc/claude-code/managed-settings.json` and prompt for sudo.

## ai-guardian Config

- Edit ai-guardian config at `config/ai-guardian/ai-guardian.json` (deploys to `~/.config/ai-guardian/ai-guardian.json` via `make reconcile`).
- Config sections (`scan_pii`, `secret_scanning`, `prompt_injection`, `config_file_scanning`, etc.) **replace defaults wholesale** — ai-guardian's `_load_config_section` in [config_loaders.py](https://github.com/jewzaam/my-claude-stuff) returns `config.get(key, defaults)` with no deep merge.
- To override one field in a section, reproduce the **entire section** (all sibling fields: `enabled`, `action`, `ignore_files`, `ignore_tools`, `allowlist_patterns`, etc.) from defaults. Omitting siblings silently drops them.
