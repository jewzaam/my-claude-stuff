# my-claude-stuff

Claude Code configuration and statusline scripts with cross-platform support (Linux/Windows).

## What's in the repo

- `claude/` — Claude Code config files (`CLAUDE.md`, `settings.json`)
- `scripts/` — Python scripts for statusline, session tracking, and command blocking
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
