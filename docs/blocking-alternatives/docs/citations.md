# Citations

All sources visited in-session via WebSearch. Sources organized by research dimension.

---

## Claude Code Native Features

**[1]** "Settings." *Claude Code Documentation*, Anthropic, n.d.
<https://docs.anthropic.com/en/docs/claude-code/settings>
Data extracted: settings.json schema, permissions.allow/deny syntax, sandbox configuration, array merging behavior, precedence rules.

**[2]** "Configure permissions (SDK)." *Claude Code Documentation*, Anthropic, n.d.
<https://docs.anthropic.com/en/docs/claude-code/sdk/sdk-permissions>
Data extracted: permission modes (default, acceptEdits, bypassPermissions, plan, dontAsk), evaluation flow (deny -> ask -> allow), allowed_tools/disallowed_tools fields.

**[3]** "Hooks." *Claude Code Documentation*, Anthropic, n.d.
<https://docs.anthropic.com/en/docs/claude-code/hooks>
Data extracted: all hook event types, PreToolUse/PostToolUse schemas, exit code semantics, matcher syntax. Timeout default: 10 minutes (increased from 60 seconds in v2.1.3).

**[4]** "Hooks guide." *Claude Code Documentation*, Anthropic, n.d.
<https://docs.anthropic.com/en/docs/claude-code/hooks-guide>
Data extracted: PreToolUse examples, structured JSON output format, permissionDecision values (allow/deny/ask), updatedInput and additionalContext capabilities.

**[5]** "Security." *Claude Code Documentation*, Anthropic, n.d.
<https://docs.anthropic.com/en/docs/claude-code/security>
Data extracted: built-in guardrails (command injection detection, fail-closed matching, command blocklist blocking curl/wget), input sanitization.

**[6]** "CLI reference." *Claude Code Documentation*, Anthropic, n.d.
<https://docs.anthropic.com/en/docs/claude-code/cli-reference>
Data extracted: --dangerously-skip-permissions flag behavior, deny rules and hooks still evaluated in bypass mode.

**[7]** "Development containers." *Claude Code Documentation*, Anthropic, n.d.
<https://docs.anthropic.com/en/docs/claude-code/devcontainer>
Data extracted: devcontainer security model, firewall isolation, credential exfiltration warning.

---

## Community Claude Code Hooks

**[8]** "Destructive Command Guard (dcg)." *GitHub*, Dicklesworthstone, n.d.
<https://github.com/Dicklesworthstone/destructive_command_guard>
Data extracted: three-tier pipeline with SIMD-accelerated quick-reject, <10us for 95%+ commands, blocks git/filesystem/database/container/cloud destructive ops. Rust (Edition 2024). Origin: December 17, 2025 data loss incident.
Note: Star count not confirmed via API. Data from search result summaries.

**[9]** "claude-code-safety-net." *GitHub*, kenryu42, n.d.
<https://github.com/kenryu42/claude-code-safety-net>
Data extracted: semantic argument parsing, shell wrapper analysis, safe/dangerous variant distinction, strict/paranoid modes, custom rules (additive only). TypeScript/Bun.
Note: Star count not confirmed via API.

**[10]** "claude-code-config." *GitHub*, Trail of Bits, n.d.
<https://github.com/trailofbits/claude-code-config>
Data extracted: opinionated defaults for Claude Code, bypass-permissions mode with hooks as guardrails. Critical quote: "hooks are not a security boundary — they are structured prompt injection at opportune times."

**[11]** "claude-guardrails." *GitHub*, Dwarves Foundation, n.d.
<https://github.com/dwarvesf/claude-guardrails>
Data extracted: lite (3 hooks, 15 deny rules) and full (5 hooks + PostToolUse prompt injection scanner) variants. Shell/npm. Prompt injection scanner acknowledged as noisy.

**[12]** "claude-code-damage-control." *GitHub*, disler, n.d.
<https://github.com/disler/claude-code-damage-control>
Data extracted: five protection layers (command blocking, ask patterns, zero-access paths, read-only paths, no-delete paths). YAML config. Python/UV and Bun/TypeScript dual implementations. 355 stars, 65 forks.
Note: Star count from search result text, not API verification.

**[13]** "nah." *GitHub*, manuelschipper, n.d.
<https://github.com/manuelschipper/nah>
Data extracted: context-aware safety guard that classifies tool calls using contextual rules. Known limitation: --dangerously-skip-permissions causes async hook firing.
Note: Very recent project (~March 12, 2026). Original research described "20-type taxonomy" and ".nah.yaml tighten-only config" but audit could not confirm these specific features.

**[14]** "claude-code-permissions-hook." *GitHub*, kornysietsma, n.d.
<https://github.com/kornysietsma/claude-code-permissions-hook>
Data extracted: TOML-based allow/deny with regex patterns. Rust. Windows .NET port exists.

**[15]** "claude-security-guardrails." *GitHub*, mafiaguy, n.d.
<https://github.com/mafiaguy/claude-security-guardrails>
Data extracted: 30+ risky patterns, React dashboard at localhost:3001, Docker support.

**[16]** "claude-code-guardrails." *GitHub*, Rulebricks, n.d.
<https://github.com/rulebricks/claude-code-guardrails>
Data extracted: cloud-based visual rule editor, live mid-session updates, logging/analytics.
Note: Requires Rulebricks cloud platform; data privacy considerations.

**[17]** "sentinel-ai." *GitHub*, MaxwellCalkin, n.d.
<https://github.com/MaxwellCalkin/sentinel-ai>
Data extracted: prompt injection detection (12 languages), PII leak detection, OWASP vulnerability scanning.
Note: Original research reported "100% accuracy on 500-case benchmark" but audit found no such claim in any source. Removed.

**[18]** "awesome-claude-code." *GitHub*, hesreallyhim, n.d.
<https://github.com/hesreallyhim/awesome-claude-code>
Data extracted: curated list of hooks, skills, plugins. ~29,000 stars.

**[19]** "claude-code-hooks." *GitHub*, karanb192, n.d.
<https://github.com/karanb192/claude-code-hooks>
Data extracted: ready-to-use hooks for safety, automation, notifications. 194 stars.

**[20]** "RCE and API Token Exfiltration through Claude Code Project Files." *Check Point Research*, February 2026.
<https://research.checkpoint.com/2026/rce-and-api-token-exfiltration-through-claude-code-project-files-cve-2025-59536/>
Data extracted: CVE-2025-59536 (CVSS 8.7, code injection via trust-dialog bug), CVE-2026-21852 (CVSS 5.3, project-load API key exfiltration) — malicious project files could define hooks executing automatically. All patched by Anthropic.
Note: Original research included CVE-2026-24887 but audit found it was not part of the Check Point disclosure.

---

## AI Agent Guardrail Tools

**[21]** "Sandboxing — Codex." *OpenAI Developers*, n.d.
<https://developers.openai.com/codex/concepts/sandboxing>
Data extracted: SandboxPolicy enum (ReadOnly, WorkspaceWrite, DangerFullAccess, ExternalSandbox), OS-level mechanisms (Seatbelt/macOS, Landlock+seccomp/Linux, Restricted Token/Windows).

**[22]** "Agent approvals & security — Codex." *OpenAI Developers*, n.d.
<https://developers.openai.com/codex/agent-approvals-security>
Data extracted: approval presets (suggest, auto-edit, on-request/full-auto), --dangerously-bypass-approvals-and-sandbox (--yolo).

**[23]** "Security — Codex." *OpenAI Developers*, n.d.
<https://developers.openai.com/codex/security>
Data extracted: process hardening (PR_SET_DUMPABLE, RLIMIT_CORE, LD_PRELOAD stripping).

**[24]** "linux-sandbox README." *GitHub*, openai/codex, n.d.
<https://github.com/openai/codex/blob/main/codex-rs/linux-sandbox/README.md>
Data extracted: seccomp blocked syscalls (ptrace, init_module, delete_module, reboot), allowed syscalls (read, write, open, close, stat, fork, exec). x86_64 and aarch64 only.

**[25]** "CVE-2026-22708: Bypassing Cursor AI's Safe Mode via Shell Built-ins." *DEV Community*, cverports, n.d.
<https://dev.to/cverports/cve-2026-22708-trust-issues-bypassing-cursor-ais-safe-mode-via-shell-built-ins-55ao>
Data extracted: shell built-in bypass of Cursor Auto-Run allowlist, environment poisoning via export/alias.

**[26]** "Cursor Vulnerability CVE-2025-59944." *Lakera*, n.d.
<https://www.lakera.ai/blog/cursor-vulnerability-cve-2025-59944>
Data extracted: case-sensitivity file path bypass on case-insensitive filesystems. Fixed in Cursor v1.7.

**[27]** "Cursor AI safeguards easily bypassed in YOLO mode." *The Register*, July 21, 2025.
<https://www.theregister.com/2025/07/21/cursor_ai_safeguards_easily_bypassed/>
Data extracted: four denylist bypass methods (base64 encoding, subshell wrapping, script indirection, double-quote variations). Backslash Security disclosure.

**[28]** "Git integration." *Aider Documentation*, n.d.
<https://aider.chat/docs/git.html>
Data extracted: auto-commit safety net, --no-auto-commits, --no-dirty-commits. No built-in sandboxing.

**[29]** "Options reference." *Aider Documentation*, n.d.
<https://aider.chat/docs/config/options.html>
Data extracted: --no-suggest-shell-commands, --yes-always (does NOT auto-run shell commands), --dry-run, --read (read-only files).

**[30]** "RoguePilot: Critical GitHub Copilot Vulnerability." *Orca Security*, n.d.
<https://orca.security/resources/blog/roguepilot-github-copilot-vulnerability/>
Data extracted: symlink-based guardrail bypass in Copilot Codespaces, repository takeover via file_read without triggering workspace boundary restrictions.

**[31]** "Security considerations and best practices — Amazon Q Developer." *AWS Documentation*, n.d.
<https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/command-line-chat-security.html>
Data extracted: tool permission model (fs_read=trusted, execute_bash=prompts, use_aws=prompts).
**Access:** Page returned JavaScript redirect; data from search summaries.

**[32]** "Managing tool permissions — Amazon Q Developer." *AWS Documentation*, n.d.
<https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/command-line-chat-tools.html>
Data extracted: toolsSettings with allowedPaths/deniedPaths for fs_write, allowedCommands/deniedCommands for execute_bash.

**[33]** "Security Bug: Denied Commands Not Properly Enforced." *GitHub*, aws/amazon-q-developer-cli, Issue #2477.
<https://github.com/aws/amazon-q-developer-cli/issues/2477>
Data extracted: denied commands execute and return output before permission system denies them.

**[34]** "IronCurtain." *Starlog*, n.d.
<https://starlog.is/articles/ai-agents/provos-ironcurtain/>
Data extracted: semantic interposition on MCP tool calls, English-to-deterministic-rules pipeline, V8 isolate execution. 14 filesystem tools, 28 git tools.

**[35]** "LlamaFirewall: An Open Source Guardrail System for Building Secure AI Agents." *Meta Research*, 2025.
<https://ai.meta.com/research/publications/llamafirewall-an-open-source-guardrail-system-for-building-secure-ai-agents/>
Data extracted: PromptGuard 2 (86M/22M params), Agent Alignment Checks (chain-of-thought auditor), CodeShield (96% precision, 79% recall). >90% reduction in attack success on AgentDojo benchmark.

**[36]** "Security-Focused Guide for AI Code Assistant Instructions." *OpenSSF*, September 2025.
<https://best.openssf.org/Security-Focused-Guide-for-AI-Code-Assistant-Instructions.html>
Data extracted: standardized security instructions for AI coding assistants. Finding: "62% of AI-generated code solutions contain design flaws or known security vulnerabilities."

**[37]** "Auto Approve & YOLO Mode." *Cline Documentation*, n.d.
<https://docs.cline.bot/features/auto-approve>
Data extracted: Plan/Act mode separation, granular auto-approve toggles, LLM-evaluated requires_approval flag, maximum requests setting.

**[38]** "Cline Bot AI Coding Agent Vulnerabilities." *Mindgard*, n.d.
<https://mindgard.ai/blog/cline-coding-agent-vulnerabilities>
Data extracted: malicious .clinerules file can force requires_approval=false on all exec_command calls.

---

## Container/Sandbox Approaches

**[39]** "Sandboxing." *Claude Code Documentation*, Anthropic, n.d.
<https://code.claude.com/docs/en/sandboxing>
Data extracted: bubblewrap (Linux), Seatbelt (macOS), network proxy model, sandbox.filesystem/network config, dangerouslyDisableSandbox escape hatch, enableWeakerNestedSandbox mode.

**[40]** "Claude Code Sandboxing." *Anthropic Engineering Blog*, n.d.
<https://www.anthropic.com/engineering/claude-code-sandboxing>
Data extracted: "sandboxing safely reduces permission prompts by 84%" (first-party claim).
Note: First-party claim, no independent verification.

**[41]** "Docker Sandboxes." *Docker Blog*, n.d.
<https://www.docker.com/blog/docker-sandboxes-run-claude-code-and-other-coding-agents-unsupervised-but-safely/>
Data extracted: microVM-based isolation (macOS/Windows), container-based on Linux, --dangerously-skip-permissions by default. CVE-2025-9074 (CVSS 9.3) Docker Desktop Engine API exposure.
Note: Original research reported CVE-2025-907418; audit corrected to CVE-2025-9074.

**[42]** "How Claude Code Escapes Its Own Denylist and Sandbox." *ona.com*, n.d.
<https://ona.com/stories/how-claude-code-escapes-its-own-denylist-and-sandbox>
Data extracted: agent observed autonomously disabling bubblewrap sandbox when it interfered with task completion.

**[43]** "nsjail." *GitHub*, google/nsjail, n.d.
<https://github.com/google/nsjail>
Data extracted: Linux namespaces + seccomp-bpf + cgroups, ProtoBuf config, Kafel BPF language.

**[44]** "Agent Boundaries." *Coder Documentation*, n.d.
<https://coder.com/docs/ai-coder/agent-boundaries>
Data extracted: nsjail for network filtering, GA in Coder v2.30 (February 2026), AI Governance Add-On.

**[45]** "gVisor improves performance with root filesystem overlay." *Google Open Source Blog*, April 2023.
<https://opensource.googleblog.com/2023/04/gvisor-improves-performance-with-root-filesystem-overlay.html>
Data extracted: VFS2 50-75% filesystem improvement, LISAFS protocol 50-75% reduction, rootfs overlay halved sandboxing overhead.

**[46]** "True overhead of gVisor." *USENIX HotCloud '19*, Young et al.
<https://www.usenix.org/system/files/hotcloud19-paper-young.pdf>
Data extracted: simple syscalls 2.2x slower, file open/close on tmpfs 216x slower, runc 32% slower than native.
Note: 2019 paper; significant optimizations since.

**[47]** "Firecracker." *GitHub*, firecracker-microvm/firecracker, n.d.
<https://github.com/firecracker-microvm/firecracker>
Data extracted: 125ms boot, <5 MiB memory, up to 150 microVMs/sec/host. Powers AWS Lambda/Fargate.

**[48]** "How I Built Sandboxes That Boot in 28ms Using Firecracker Snapshots." *DEV Community*, Adwitiya, n.d.
<https://dev.to/adwitiya/how-i-built-sandboxes-that-boot-in-28ms-using-firecracker-snapshots-i0k>
Data extracted: 28ms snapshot restore time.

**[49]** "Bubblewrap." *GitHub*, containers/bubblewrap, n.d.
<https://github.com/containers/bubblewrap>
Data extracted: unprivileged sandboxing via user namespaces, used by Flatpak, used by Claude Code on Linux.

**[50]** "Bubblewrap." *Arch Wiki*, n.d.
<https://wiki.archlinux.org/title/Bubblewrap>
Data extracted: CLONE_NEWUSER, CLONE_NEWPID, CLONE_NEWNET namespace support.

**[51]** "sandbox-exec." *Igor's Techno Club*, n.d.
<https://igorstechnoclub.com/sandbox-exec/>
Data extracted: deprecated but still functional, SBPL (Scheme) profile language, used by Bazel.

**[52]** "Isolating AI Agents with DevContainer." *DEV Community*, siddhantkcode, n.d.
<https://dev.to/siddhantkcode/isolating-ai-agents-with-devcontainer-a-secure-and-scalable-approach-4hi4>
Data extracted: devcontainer.json configuration for AI agent isolation.

**[53]** "Coding Agents in Secured VS Code Dev Containers." *danieldemmel.me*, n.d.
<https://www.danieldemmel.me/blog/coding-agents-in-secured-vscode-dev-containers>
Data extracted: VS Code Unix socket escape vectors, Docker socket + passwordless sudo risks.

**[54]** "E2B." *GitHub*, e2b-dev/E2B, n.d.
<https://github.com/e2b-dev/E2B>
Data extracted: Firecracker microVMs, <200ms init, <5 MiB memory, ~8,900 stars, Apache-2.0.

**[55]** "Kubernetes Agent Sandbox." *GitHub*, kubernetes-sigs/agent-sandbox, n.d.
<https://github.com/kubernetes-sigs/agent-sandbox>
Data extracted: gVisor isolation, WarmPools, Python SDK. Launched KubeCon Atlanta November 2025.

**[56]** "ai-jail." *GitHub*, akitaonrails/ai-jail, n.d.
<https://github.com/akitaonrails/ai-jail>
Data extracted: multi-OS (bwrap on Linux, sandbox-exec on macOS), per-project config, --lockdown mode, Landlock LSM V3+V4.

---

## Shell-Level Security Tools

**[57]** "AppArmor/HowToUse." *Debian Wiki*, n.d.
<https://wiki.debian.org/AppArmor/HowToUse>
Data extracted: profile creation workflow (aa-genprof, aa-logprof, aa-enforce), enforce vs. complain modes.

**[58]** "Profile components and syntax." *SUSE Documentation*, n.d.
<https://documentation.suse.com/sles/15-SP6/html/SLES-all/cha-apparmor-profiles.html>
Data extracted: path-based model, file access rules, capability restrictions, network access rules.

**[59]** "The AppArmor Performance Impact In 70+ Benchmarks." *Phoronix*, n.d.
<https://www.phoronix.com/news/AppArmor-Linux-5.5-72-Tests>
Data extracted: ~5% overall slowdown on 72 benchmarks (Linux 5.5, Threadripper 3970X), includes known Hackbench regression. FFmpeg encoding ~3% overhead.

**[60]** "CrackArmor: Critical AppArmor Flaws Enable Local Privilege Escalation." *Qualys*, March 12, 2026.
<https://blog.qualys.com/vulnerabilities-threat-research/2026/03/12/crackarmor-critical-apparmor-flaws-enable-local-privilege-escalation-to-root>
Data extracted: nine vulnerabilities (no official CVE tracking numbers assigned), confused deputy flaws since kernel v4.11, 12.6M+ affected systems.
Note: Original research reported CVE-2026-23268/23269; audit found no such CVEs exist. Sources confirm no official tracking numbers were assigned.

**[61]** "The Performance Cost To SELinux On Fedora 31." *Phoronix*, n.d.
<https://www.phoronix.com/review/fedora-31-selinux>
Data extracted: low single-digit percentage overhead for typical workloads, >100% for micro-operations.

**[62]** "Improving the performance and space efficiency of SELinux." *Red Hat Blog*, n.d.
<https://www.redhat.com/en/blog/improving-performance-and-space-efficiency-selinux>
Data extracted: policy load time 1.3s -> 106ms (12x), policy rebuild 21.9s -> 5.7s, memory 30MB -> 15MB.

**[63]** "Optimizing seccomp usage in gVisor." *gVisor Blog*, February 2024.
<https://gvisor.dev/blog/2024/02/01/seccomp/>
Data extracted: removed up to 3.4 seconds from ABSL build (~3.6% of total runtime), binary search tree optimization, filter caching.

**[64]** "Seccomp BPF." *Linux Kernel Documentation*, n.d.
<https://docs.kernel.org/userspace-api/seccomp_filter.html>
Data extracted: 4,096 max BPF instructions per filter, 32,768 total across stacked filters.

**[65]** "Bypassing Bash Restrictions — Rbash." *VeryLazyTech*, n.d.
<https://www.verylazytech.com/linux/bypassing-bash-restrictions-rbash>
Data extracted: SSH bypass, text editor escapes, pager escapes, programming language escapes, wildcard substitution, hex encoding.

**[66]** "Linux Restricted Shell Bypass Guide." *Exploit-DB*, n.d.
<https://www.exploit-db.com/docs/english/44592-linux-restricted-shell-bypass-guide.pdf>
Data extracted: comprehensive bypass catalog. Consensus: rbash is "trivially bypassed."

**[67]** "capabilities(7)." *man7.org*, n.d.
<https://man7.org/linux/man-pages/man7/capabilities.7.html>
Data extracted: ~40 capabilities, five capability sets (Permitted, Effective, Inheritable, Bounding, Ambient), securebits flags.

**[68]** "Landlock: unprivileged access control." *Linux Kernel Documentation*, n.d.
<https://docs.kernel.org/userspace-api/landlock.html>
Data extracted: unprivileged process self-restriction via three syscalls, ABI versions 1-6 (filesystem, network, ioctl, scoping), max 16 stacked layers, monotonically decreasing privileges.

**[69]** "Landlock." *landlock.io*, n.d.
<https://landlock.io/>
Data extracted: available since kernel 5.13, no root required, no system-wide configuration needed.

**[70]** "pledge(2)." *OpenBSD Manual Pages*, n.d.
<https://man.openbsd.org/pledge.2>
Data extracted: promise categories (stdio, rpath, wpath, cpath, inet, dns, proc, exec, settime), SIGABRT on violation, subsequent calls can only reduce abilities.

**[71]** "unveil(2)." *OpenBSD Manual Pages*, n.d.
<https://man.openbsd.org/unveil.2>
Data extracted: path+flags (rwxc) restrictions, unveil(NULL, NULL) locks filesystem view permanently.

**[72]** "Porting OpenBSD pledge() to Linux." *justine.lol*, Justine Tunney, n.d.
<https://justine.lol/pledge/>
Data extracted: Linux port via seccomp-bpf, x86-64 only, incompatible with glibc, EPERM instead of SIGABRT, no path-based filtering in seccomp.

**[73]** "Container security fundamentals part 5: AppArmor and SELinux." *Datadog Security Labs*, n.d.
<https://securitylabs.datadoghq.com/articles/container-security-fundamentals-part-5/>
Data extracted: defense-in-depth model — capabilities (layer 1), seccomp (layer 2), AppArmor/SELinux (layer 3). seccomp is voluntary; AppArmor/SELinux are mandatory.
