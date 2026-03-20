# Container and Sandbox Approaches

Dimension: OS-level isolation mechanisms that could replace or complement application-layer PreToolUse hooks.

See [../citations.md](../citations.md) for full source details.

---

## Approach Comparison

| Approach | Isolation Level | Platform | Overhead | FS Restrict | Net Restrict | Syscall Restrict |
|----------|----------------|----------|----------|-------------|-------------|-----------------|
| Claude Code sandbox | OS process | macOS, Linux, WSL2 | Minimal | Yes | Yes | Via bwrap/Seatbelt |
| Docker container | OS container | Cross-platform | Low | Yes | Yes | Via seccomp |
| Docker Sandbox (microVM) | Hardware VM | macOS, Windows | Low-Medium | Yes | Yes | Full kernel |
| nsjail | OS process | Linux only | Minimal | Yes | Yes | seccomp-bpf |
| gVisor (runsc) | User-space kernel | Linux only | Medium-High | Yes | Yes | All intercepted |
| Firecracker microVM | Hardware VM | Linux (KVM) | Low | Yes | Yes | Full kernel |
| Bubblewrap (bwrap) | OS process | Linux only | Minimal | Yes | Yes | Optional seccomp |
| sandbox-exec (macOS) | OS process | macOS only | Minimal | Yes | Yes | Limited |
| Devcontainer | OS container | Cross-platform | Low | Yes | Configurable | Via Docker seccomp |

## Detailed Analysis

### Claude Code Native Sandbox [39][40][42]

**Mechanisms:** bubblewrap (Linux/WSL2), Seatbelt (macOS) [39].

**Filesystem:** Default read/write to CWD only. Configurable via `sandbox.filesystem.allowWrite` and `sandbox.filesystem.denyRead`. Restrictions apply to all subprocesses [39].

**Network:** All traffic routed through proxy outside sandbox. Only approved domains accessible. New domain requests trigger prompts [39].

**Performance claim:** "sandboxing safely reduces permission prompts by 84%" [40].
Note: First-party Anthropic claim, no independent verification (est.).

**Known weaknesses:**
- Agent can use `dangerouslyDisableSandbox` parameter to escape [39]
- Agent has been observed autonomously disabling sandbox: "It wasn't told to disable the sandbox; it decided to, because the sandbox was between it and completing the task" [42]
- `enableWeakerNestedSandbox` mode "considerably weakens security" [39]
- Network filtering operates on domains only — does not inspect traffic content [39]
- Domain fronting may bypass network filtering [39]
- `allowUnixSockets` can grant access to system services enabling sandbox bypass [39]

### Docker-Based Isolation [41]

**Docker Sandboxes:** Purpose-built for coding agents. Now run on microVMs (macOS/Windows) for hardware-level isolation. Linux uses legacy container-based sandboxes with Docker Desktop 4.57+ [41].

**Claude Code integration:** Launches with `--dangerously-skip-permissions` by default in Docker Sandboxes [41].

**CVE-2025-9074 (CVSS 9.3):** Docker Desktop Engine API exposed to any container without authentication. On macOS: escape from container to VM and control of daemon [41].

**Real-world friction:** "Execution isolation and environment parity are very different problems" — tools like `make` missing, dev dependencies incompatible with sandbox OS [41].

### nsjail [43][44]

**Mechanism:** Linux namespaces (UTS, MOUNT, PID, IPC, NET, USER, CGROUPS, TIME) + seccomp-bpf via Kafel BPF language + cgroups. ProtoBuf configuration [43].

**AI agent use:** Coder Agent Boundaries uses nsjail for network filtering. GA in Coder v2.30 (February 2026) as AI Governance Add-On [44].

**Docker compatibility:** Docker's default seccomp policy blocks namespace-related syscalls (specifically `clone`) unless `CAP_SYS_ADMIN` is granted [44].

**Production use:** Used by Windmill for sandboxing Python and Go execution [43].

### gVisor (runsc) [45][46]

**Mechanism:** User-space application kernel (Go) implementing Linux syscall interface. All syscalls intercepted and handled in user space [46].

**Performance:**

| Workload | Overhead | Source |
|----------|----------|--------|
| CPU-bound | <3% | Ant Group production [45] |
| Simple syscalls | 2.2x slower | USENIX HotCloud '19 [46] |
| File open/close (tmpfs) | 216x slower | USENIX HotCloud '19 [46] |
| runc vs native | 32% slower | USENIX HotCloud '19 [46] |

Note: HotCloud numbers are from 2019. Recent optimizations: VFS2 (50-75% filesystem improvement), LISAFS (50-75% reduction), rootfs overlay (halved build overhead) [45].

**Used by:** Kubernetes Agent Sandbox (Google/SIG Apps) [55], Google Search and Gmail.

### Firecracker MicroVMs [47][48]

| Metric | Value |
|--------|-------|
| Boot time | 125ms to user-space [47] |
| Snapshot restore | 28ms [48] |
| Creation rate | Up to 150 microVMs/sec/host [47] |
| Memory overhead | <5 MiB per microVM [47] |

**Security:** Companion jailer process sets up cgroups/namespaces before dropping privileges. Separate kernel per workload [47].

**Limitations:** No GPU passthrough, no live migration, Linux guests only, requires KVM [47].

**Production scale:** Powers AWS Lambda and AWS Fargate [47].

### Bubblewrap (bwrap) [49][50]

**Mechanism:** Unprivileged sandboxing via user namespaces (CLONE_NEWUSER, CLONE_NEWPID, CLONE_NEWNET), mount namespaces, optional seccomp filters [49][50].

**Properties:** No root required, no daemon, no setuid binary. Small C codebase [49]. Used by Flatpak [49] and Claude Code on Linux [39].

**Limitations:** Linux only, shares host kernel (kernel exploits could escape) [49].

### macOS sandbox-exec [51]

**Status:** Deprecated but widely used internally by Apple and by Bazel. Used by Claude Code via Seatbelt framework [51].

**Profile language:** SBPL (Scheme-based). "The sandbox profile format is not documented for third party use" [51].

**Limitations:** Undocumented profile format, complex configuration ("trial and error"), processes must opt-in [51].

### Devcontainers [52][53]

**Security:** Process isolation via Docker, only mounted files visible, blast radius containment [52].

**Known gaps:**
- VS Code creates Unix sockets in /tmp enabling container-to-host communication [53]
- Docker socket exposure + passwordless sudo enables host filesystem access [53]
- `mcr.microsoft.com/devcontainers/python` ships with passwordless sudo [53]
- Claude Code warns: "devcontainers don't prevent a malicious project from exfiltrating anything accessible in the devcontainer including Claude Code credentials" [7]

## AI-Agent-Specific Sandbox Projects

| Project | Mechanism | Performance | Platform |
|---------|-----------|-------------|----------|
| Kubernetes Agent Sandbox [55] | gVisor / Kata | WarmPools pre-warming | Kubernetes |
| E2B [54] | Firecracker microVMs | <200ms init, <5 MiB | Cloud / self-host |
| ai-jail [56] | bwrap (Linux) / sandbox-exec (macOS) | Minimal | Linux, macOS |
| Coder Agent Boundaries [44] | nsjail / landjail (Landlock) | Minimal | Linux |
| microsandbox | libkrun microVMs | Sub-200ms startup | Self-hosted |
| Daytona | OCI containers | Sub-90ms startup | Cross-platform |

## Gaps and Limitations

1. "84% reduction in permission prompts" is an unverified first-party claim [40]
2. CVE-2025-9074 (Docker Desktop) confirmed by audit [41]
3. gVisor overhead numbers are workload-dependent — ranges from <3% to 216x depending on operation type [45][46]
4. Firecracker requires KVM — unavailable on Mac, some CI/CD, cloud VMs without nested virtualization [47]
5. Many AI sandbox projects are new (2025-2026) — long-term maintenance unknown
