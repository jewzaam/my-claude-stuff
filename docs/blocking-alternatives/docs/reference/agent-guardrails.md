# AI Coding Agent Guardrail Tools

Dimension: how other AI coding agents handle command blocking, sandboxing, and safety.

See [../citations.md](../citations.md) for full source details.

---

## Agent Comparison Matrix

| Feature | Codex CLI | Cursor | Aider | Copilot | Amazon Q CLI | Cline | Claude Code |
|---------|-----------|--------|-------|---------|-------------|-------|-------------|
| OS-level sandbox | Yes [21] | No | No | Undisclosed | No | No | Yes [39] |
| Syscall filtering | seccomp-bpf [24] | No | No | No | No | No | Via bwrap [39] |
| Network blocking | Kernel-enforced [21] | No | No | Undisclosed | No | No | Proxy-based [39] |
| Filesystem isolation | Landlock [21] | No | No | Undisclosed | App-level [32] | No | bwrap/Seatbelt [39] |
| Command denylist | Via approval policy | App-level (bypassed) [25][27] | No | VS Code settings | Yes (buggy) [33] | LLM-evaluated [37] | Via hooks |
| Deterministic enforcement | Yes (kernel) | No (LLM + string) | N/A | Undisclosed | Partially | No (LLM) | Depends on hook |
| Known bypasses | None found | 4 CVEs + 2 bypasses [25][26][27] | N/A | 1 [30] | 1 bug [33] | 1 [38] | 3 (patched) [20] |

## Detailed Analysis

### OpenAI Codex CLI [21][22][23][24]

**Two-layer security model:**

**Layer 1 — Sandbox (what the agent CAN do):**

| Level | Filesystem | Network |
|-------|-----------|---------|
| ReadOnly | Read-only everywhere | Off |
| WorkspaceWrite | Write to CWD + /tmp | Off by default |
| DangerFullAccess | Unrestricted | On |
| ExternalSandbox | External enforcement | External enforcement |

**Layer 2 — Approval (when the agent ASKS):**

| Preset | File edits | Commands |
|--------|-----------|----------|
| `suggest` | Asks | Asks |
| `auto-edit` | Auto-approves | Asks |
| `on-request` / `--full-auto` | Auto-approves | Auto-approves (within sandbox) |
| `--yolo` | All bypassed | All bypassed |

**OS-level mechanisms (pure Rust, no external dependencies):**

| Platform | Mechanism |
|----------|-----------|
| macOS | Seatbelt (sandbox-exec profile) |
| Linux | Landlock LSM + seccomp-bpf |
| Windows | Restricted Token |

**Seccomp blocked syscalls:** ptrace, init_module, delete_module, reboot, network socket creation (except AF_UNIX) [24].

**Process hardening:** `prctl(PR_SET_DUMPABLE, 0)`, `RLIMIT_CORE=0`, `LD_PRELOAD` stripped [23].

**Architecture support:** x86_64 and aarch64 only [24].

**Key differentiator:** Only AI coding agent with kernel-enforced, deterministic sandboxing across all three major platforms.

### Cursor [25][26][27]

**Safety architecture:** Command allowlist/denylist for Auto-Run (YOLO) mode. No OS-level sandboxing [25].

**Known CVEs:**

| CVE | Issue | Impact |
|-----|-------|--------|
| CVE-2026-22708 [25] | Shell built-in bypass (export, alias, source ignored by allowlist) | Full RCE |
| CVE-2025-59944 [26] | Case-sensitive path comparison on case-insensitive FS | Path restriction bypass |
| CVE-2025-54135 | Malicious Slack messages rewrite MCP config | Arbitrary command execution |
| CVE-2025-54136 | Shared repo MCP configs execute backdoors post-approval | Team-wide compromise |
| Denylist bypass [27] | Base64 encoding, subshell wrapping, script indirection, double-quote variations | Denylist is unreliable |
| Allowlist + `&&` | `cd dir && dangerous-cmd` passes despite dangerous-cmd not in allowlist | Chain bypass |

**Assessment:** Multiple independent security researchers have demonstrated bypasses. Application-layer string matching without OS enforcement has fundamental limitations [25][27].

### Aider [28][29]

**Safety model:** Minimal — relies on user discipline and git.

- No command blocking, no sandboxing, no filesystem restrictions [28][29]
- Git auto-commits as safety net (can `git revert`) [28]
- `--no-suggest-shell-commands` disables shell command suggestions entirely [29]
- `--yes-always` does NOT auto-run shell commands [29]
- Files must be explicitly added to conversation context [28]
- `--read` adds files as read-only context [29]

### GitHub Copilot [30]

- Human-in-the-loop: editable specs, plan review, diff approval before push/merge
- No published execution environment details
- **RoguePilot vulnerability:** symlink-based bypass of workspace boundaries — agent read secrets via symlinks without triggering restrictions [30]
- Community: users run Copilot CLI inside Docker for isolation

### Amazon Q Developer CLI [31][32][33]

**Tool permission model:**

| Tool | Default Trust |
|------|--------------|
| `fs_read` | Trusted (no prompt) |
| `execute_bash` | Prompts |
| `fs_write` | Prompts |
| `use_aws` | Prompts |

**Configuration:** `allowedPaths`/`deniedPaths` for fs_write, `allowedCommands`/`deniedCommands` for execute_bash. Deny rules evaluated before allow rules [32].

**Critical bug:** "Commands in deniedCommands are executed and return output *before* the permission system denies them" (Issue #2477) [33].

**No OS-level sandboxing** — no Landlock, seccomp, or Seatbelt [31].

### Cline [37][38]

- Plan Mode (read-only) vs Act Mode (read/write) — user must explicitly switch [37]
- Granular auto-approve toggles for read ops, write ops, terminal commands, browser actions [37]
- LLM evaluates commands and sets `requires_approval` flag [37]
- **Vulnerability:** malicious `.clinerules` file can force `requires_approval=false` on all commands [38]
- **No OS-level sandboxing** [37]

## Cross-Agent Frameworks

### IronCurtain [34]

**Approach:** Semantic interposition on MCP tool calls (not raw syscalls). English-to-deterministic-rules pipeline — write intent in plain English, system compiles to deterministic if/then rules enforced without LLM at runtime. Agent code runs in V8 isolate [34].

**Key quote:** "Unlike guardrails that rely on the LLM itself, the policy engine operates entirely outside the model" [34].

**Capabilities:** 14 filesystem tools, 28 git tools, web fetching/search, Signal integration. Install via `npx @provos/ironcurtain` [34].

### LlamaFirewall (Meta) [35]

Three components:
1. **PromptGuard 2** — jailbreak/prompt injection detection (86M and 22M parameter variants)
2. **Agent Alignment Checks** — chain-of-thought auditor for goal hijacking detection
3. **CodeShield** — static analysis for insecure code (96% precision, 79% recall)

Performance: >90% reduction in attack success on AgentDojo benchmark [35].

### OpenSSF Guide [36]

Standardized security instructions for AI coding assistant custom prompts. Finding: "62% of AI-generated code solutions contain design flaws or known security vulnerabilities" [36].

## Gaps and Limitations

1. Codex CLI seccomp blocked syscall list uses "etc." — full list is in source code, not exhaustively documented [24]
2. Cursor denylist deprecation reported by Backslash/The Register but not confirmed by official Cursor announcement [27]
3. Amazon Q docs page returned JavaScript redirect; data from search summaries [31]
4. GitHub Copilot Workspace has very limited public documentation on internal security mechanisms [30]
5. CVE-2026-22708 (Cursor) has a 2026 CVE number — date should be independently verified [25]
