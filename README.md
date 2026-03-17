# my-claude-stuff

Claude Code configuration and statusline scripts with cross-platform support (Linux/Windows).

## What's in the repo

- `claude/` — Claude Code config files (`CLAUDE.md`, `settings.json`)
- `scripts/` — Python scripts for statusline and session tracking
- `Makefile` — Standard targets (format, lint, typecheck, test, coverage)

## Statusline

Custom statusline for Claude Code showing:

```
Model: Opus 4.6 (1M context) | Context: 7% | 3h4m: 11% | 4d12h: 4% (2m)
```

| Segment | Source |
|---------|--------|
| Model | Claude Code stdin |
| Context | Claude Code stdin (context window used %) |
| Quota | Anthropic OAuth usage API. Label is time until reset (e.g. `3h4m: 11%`) |
| Freshness | `(2m)` = 2 min old, fresh. `(!5m)` = 5 min old, last fetch failed |
| Session / Today | Vertex mode only — session and daily cost from stdin |

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

Requires Python 3.10+. Uses shared venv at `~/.venv/ap/` if available, otherwise local `.venv`.
