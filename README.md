# my-claude-stuff

[![test](https://github.com/jewzaam/my-claude-stuff/actions/workflows/test.yml/badge.svg)](https://github.com/jewzaam/my-claude-stuff/actions/workflows/test.yml)
[![quality](https://github.com/jewzaam/my-claude-stuff/actions/workflows/quality.yml/badge.svg)](https://github.com/jewzaam/my-claude-stuff/actions/workflows/quality.yml)
[![Python](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)

Claude Code configuration and statusline scripts with cross-platform support (Linux/Windows).

## Overview

- `claude/` — Claude Code config files (`CLAUDE.md`, `settings.json.d/`)
- `scripts/` — Python scripts for statusline, session tracking, and command blocking
- Hook fragments: [ai-guardian](https://github.com/itdove/ai-guardian) (security scanning), noop (OTEL event coverage)
- `docs/` — Design docs and reference material
- `Makefile` — Standard targets (format, lint, typecheck, test, coverage)

## Statusline

Custom statusline for Claude Code:

```
Context: 7% | 3h4m: 11% | 4d12h: 4% | S/T/P: $3.93 / $9.77 / $5.47 | Opus 4.6 | session-uuid
```

| Segment | Source | Color |
|---------|--------|-------|
| Context | Context window used % | Green/yellow/red (60%/90% thresholds) |
| Quota | Anthropic OAuth usage API. Label is time until reset | Green/yellow/red (60%/90% thresholds) |
| Freshness | Only shown on stale/error: `(!5m)` = last fetch failed | Red |
| S/T/P | Session / Today / Project cost | Blue ramp, $15 steps, saturates at $195+ |
| Model | Display name from Claude Code stdin | Orange |
| Session ID | Session UUID for prompt log correlation | Purple |

Quota labels show time remaining until the limit resets, with at most 2 units of precision (`d+h`, `h+m`, `m+s`, or single unit). Falls back to `5h`/`1w` if the reset timestamp is unavailable.

Quota data is cached for 2 minutes. On API failure (429/error), stale cache is used and the freshness indicator shows `!`.

## Refresh a provider model list

`scripts/refresh_models.py` fills `modelPicker.options` in `~/.claude/settings.json`
from a provider's `/v1/models` endpoint. It reads the provider from
`ANTHROPIC_BASE_URL` and the credential from `ANTHROPIC_API_KEY` (sent as
`x-api-key`) or `ANTHROPIC_AUTH_TOKEN` (sent as `Authorization: Bearer`).
Only one credential header is sent. Use `--auth api-key|bearer` when an
explicit `--token` needs the other header:

```bash
python3 scripts/refresh_models.py
```

Rows use the provider's `display_name` when it differs from the ID; otherwise
the label is generated from the ID. Claude models are excluded by default
because Claude Code ships them; pass `--include-anthropic` to keep them. Only
the highest version of each model class is kept: the class is everything before
the first digit, and the version is compared component-by-component,
numerically for numeric components and lexicographically otherwise. Existing
options are replaced; other settings keys are preserved. Use `--url` or
`--token` to override the environment, `--description` to label every row,
`--settings FILE` for another file, `--output FILE` to write a standalone
`modelPicker` fragment instead of updating settings, and `--dry-run` to inspect
the result first.

## Model configuration

Model access is restricted by a denylist, which is honored only in managed settings. Managed settings apply system-wide and cannot be overridden by user settings. `claude/managed-settings.json` defines `deniedModels`:

```json
{
  "deniedModels": ["fable", "haiku", "opus", "sonnet"]
}
```

`make deny-anthropic-models` installs the file to `/etc/claude-code/managed-settings.json` via `sudo`. It validates the file with `jq` and skips the write when the installed copy is unchanged; expect a sudo password prompt. `make allow-anthropic-models` removes it. Neither runs as part of `make reconcile`.

### Removing the denylist

`make allow-anthropic-models` removes the managed settings file as root. The equivalent by hand:

```bash
sudo rm /etc/claude-code/managed-settings.json
```

## Deployment

Scripts run from `~/.claude/my-claude-stuff/scripts/`, not from this repo directly. This prevents untested changes from executing immediately.

```bash
make reconcile    # copies config + scripts to ~/.claude/
```

## Development

```bash
make              # run all checks (format, lint, typecheck, test, coverage)
make test         # run tests only
make coverage     # run tests with coverage report
```

Requires Python 3.10+. Uses local `.venv` (auto-created by make targets).
