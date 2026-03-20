# Community Claude Code Hook Projects

Dimension: open-source PreToolUse hooks and guardrail projects built for Claude Code.

See [../citations.md](../citations.md) for full source details.

---

## Project Comparison

| Project | Language | Approach | Scope | Notable Feature |
|---------|----------|----------|-------|-----------------|
| dcg [8] | Rust | SIMD-accelerated regex pipeline | Git, FS, DB, K8s, Cloud | <10us for 95%+ commands |
| claude-code-safety-net [9] | TypeScript/Bun | Semantic argument parsing | Git, FS | Distinguishes safe/dangerous variants |
| Trail of Bits config [10] | Shell/jq | Opinionated defaults | Git, FS | "hooks are not a security boundary" |
| claude-guardrails [11] | Shell/npm | Lite/full variants | Git, FS, prompt injection | PostToolUse injection scanner |
| damage-control [12] | Python + TS | Five protection layers | Git, FS, paths | YAML config, ask patterns |
| nah [13] | Unknown | Structural classifier | 20-type taxonomy | Per-project can only tighten |
| permissions-hook [14] | Rust | TOML allow/deny | Configurable | Regex pattern matching |
| security-guardrails [15] | Node.js/React | 30+ patterns | Git, FS, secrets | Real-time dashboard |
| Rulebricks guardrails [16] | Python | Cloud rules engine | Configurable | Live mid-session updates |
| sentinel-ai [17] | Python | Multi-threat detection | Injection, PII, OWASP | MCP safety proxy (unverified claims) |

## Detailed Analysis

### dcg (Destructive Command Guard) [8]

**Architecture:** Three-tier pipeline:
1. Quick-reject via SIMD-accelerated keyword scan
2. Expensive regex matching only for flagged commands
3. Decision output via stdin/stdout JSON

**Coverage:** Git destructive ops, filesystem, database (PostgreSQL, MySQL, MongoDB, Redis, SQLite), containers (Docker, Podman, docker-compose), Kubernetes (kubectl, Helm, Kustomize), cloud providers (AWS, GCP, Azure).

**Performance:** 95%+ of commands pass through in <10us [8].

**Multi-agent:** Natively supports Claude Code, Gemini CLI, GitHub Copilot CLI, OpenCode, Aider (git hooks only) — 5 named agents [8].

**Philosophy:** "assumes the AI agent is well-intentioned but fallible... prioritizes never allowing dangerous commands over avoiding false positives" [8].

**Origin:** December 17, 2025 — AI agent ran `git checkout --` on uncommitted work [8].

### claude-code-safety-net [9]

**Key differentiator:** Semantic analysis that distinguishes safe from dangerous command variants [9].

Example: "Claude Code's deny rules use simple prefix matching, which can't distinguish safe vs. dangerous variants — e.g., `Bash(git checkout)` blocks both `git checkout -b new-branch` (safe) and `git checkout -- file` (dangerous)" [9].

**Modes:** `SAFETY_NET_STRICT=1` (fail-closed), `SAFETY_NET_PARANOID=1` (all checks), `SAFETY_NET_PARANOID_RM=1` (blocks non-temp rm -rf even within cwd), `SAFETY_NET_PARANOID_INTERPRETERS=1` (blocks interpreter one-liners) [9].

**Custom rules:** Additive only — cannot bypass built-in protections. User and project scopes (project overrides user) [9].

### Trail of Bits config [10]

**Philosophy:** Run Claude Code with `--dangerously-skip-permissions`, rely on hooks as guardrails [10].

**Critical caveat:** "hooks are not a security boundary — they are structured prompt injection at opportune times for intercepting tool calls and steering behavior" [10].

**Performance guidance:** Prefer shell + jq over Python (avoids interpreter startup latency), fast-fail early, favor regex over AST parsing [10].

**Also maintains:** `claude-code-devcontainer` — agent runs in a container with only project files mounted [10].

### Dwarves Foundation claude-guardrails [11]

**Two variants:**
- **Lite:** 3 hooks, 15 deny rules — for trusted projects
- **Full:** 5 hooks + PostToolUse prompt injection scanner

**Prompt injection scanner:** Pattern-matches strings like "ignore previous instructions." Noisy — triggers on legitimate security docs. Warns but doesn't block [11].

**Performance:** "With 3 hooks (lite), that's 3 extra processes per Bash tool call. With 5 hooks + PostToolUse scanner (full), it's 6. Noticeable on slower machines" [11].

**Installation:** `npx claude-guardrails install` — merges into existing settings.json with backup, safe to run repeatedly, surgical uninstall [11].

### nah [13]

**Approach:** Context-aware safety guard that classifies tool calls using contextual rules running in milliseconds (no LLM in the default path) [13].

**Known limitation:** `--dangerously-skip-permissions` causes PreToolUse hooks to fire asynchronously, meaning nah cannot block commands before they execute [13].

## Security Context

In February 2026, Check Point Research disclosed CVE-2025-59536 and CVE-2026-21852 — malicious project files could define hooks executing automatically when Claude loads an untrusted repo. All issues patched by Anthropic [20].

## Curated Collections

| Collection | Stars | Content |
|------------|-------|---------|
| awesome-claude-code [18] | ~29,000 | Skills, hooks, slash-commands, plugins |
| claude-code-hooks [19] | 194 | Ready-to-use safety/automation hooks |
| awesome-claude-code-toolkit | N/A | 135 agents, 35 skills, 19 hooks |

## Comparison to This Repo's Hooks

| Feature | This repo | dcg [8] | safety-net [9] | ToB [10] |
|---------|-----------|---------|----------------|----------|
| Language | Python | Rust | TypeScript/Bun | Shell/jq |
| Command blocking | Regex with chain splitting | SIMD + regex pipeline | Semantic argument parsing | Regex |
| Path blocking | Regex on resolved paths | N/A | N/A | N/A |
| GWS CLI blocking | Yes (extensive) | No | No | No |
| Windows commands | Yes | Unknown | No | No |
| Performance | Python startup per call | <10us for 95%+ | Unknown | Shell + jq (fast) |
| Multi-agent | Claude Code only | 5+ agents | Claude Code | Claude Code only |
| Config | Hardcoded patterns | Modular packs | Env vars + JSON | settings.json |

## Gaps and Limitations

1. Star counts unconfirmed for most projects — API access was unavailable during research
2. Last commit dates unavailable — project maintenance status unknown
3. Several projects (nah, sentinel-ai) are days or weeks old — stability unverified
4. README quotes from search result summaries, not guaranteed verbatim
5. The --dangerously-skip-permissions async hook issue [13] affects all hook-based solutions, not just nah
