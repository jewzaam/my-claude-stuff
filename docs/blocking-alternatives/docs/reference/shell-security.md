# Shell-Level Security Tools

Dimension: OS-level security mechanisms (AppArmor, SELinux, seccomp, Landlock, etc.) that could replace or complement application-layer PreToolUse hooks.

See [../citations.md](../citations.md) for full source details.

---

## Tool Comparison

| Tool | Privilege | Restricts | Overhead | Path Filtering | Bypass Risk | Complexity |
|------|-----------|-----------|----------|----------------|-------------|------------|
| AppArmor | Root | Files, caps, network | 3-5% [59] | Yes (path-based) | CrackArmor CVEs [60] | Low-Medium |
| SELinux | Root | Everything (label-based) | Low single-digit % [61] | Yes (label-based) | Complex policy errors | Very High |
| seccomp-bpf | None | Syscalls | Nanoseconds/syscall [63] | No | Cannot filter paths | Medium |
| rbash | None | cd, PATH, redirects | None | No | Trivially bypassed [65][66] | Low |
| Capabilities | CAP_SETPCAP | Privileged operations | Negligible | No | No file access control | Low |
| Landlock | **None** | Files, network, signals | Lower than seccomp (est.) | **Yes (hierarchy)** | 16-layer limit | Low-Medium |
| pledge/unveil | None (OpenBSD) | Syscall categories + paths | Negligible | **Yes (unveil)** | March 2026 errata | **Very Low** |

## Detailed Analysis

### AppArmor [57][58][59][60]

**Mechanism:** Linux Security Module implementing Mandatory Access Control via **path-based** profiles. Profiles stored in `/etc/apparmor.d/`, named after confined executable [57].

**What it restricts:** File access (read/write/execute per path), POSIX capabilities, network access (address type and family), resource limits (rlimits), child process execution modes [58].

**Profile modes:** Enforce (blocks and logs violations) and Complain (logs but allows) [57].

**Profile creation:** `aa-genprof` -> run app in complain mode -> `aa-logprof` to refine -> `aa-enforce` [57].

**Performance:** ~5% overall on 72 benchmarks (Linux 5.5, Threadripper 3970X), includes known Hackbench regression. FFmpeg encoding: ~3% overhead [59].

**CrackArmor (March 12, 2026):** Nine vulnerabilities (no official CVE tracking numbers assigned). Confused deputy flaws since kernel v4.11, affecting 12.6M+ systems. Unprivileged user can coerce privileged programs into loading/replacing/removing AppArmor profiles via pseudo-files. Enables local privilege escalation to root and container isolation bypass. Kernel patches released [60].

**Path-based weakness:** If a protected path is bind-mounted elsewhere, AppArmor will not protect the new mount point [58].

### SELinux [61][62]

**Mechanism:** Kernel security module using **label-based** Mandatory Access Control. Every process and object gets a Security Context (user, role, type, level). Policies define permissible interactions [61].

**Complexity:** Real-world policies comprise thousands of statements. Many administrators disable SELinux due to difficulty troubleshooting. Policy language has spawned multiple research projects and analysis tools [61].

**Performance:** Low single-digit percentage for typical workloads. Micro-operations (null reads/writes) can show >100% overhead. Recent Red Hat improvements: policy load 1.3s -> 106ms (12x faster), policy rebuild 21.9s -> 5.7s, memory 30MB -> 15MB [61][62].

**Assessment:** Designed for enterprise/government compliance. Overkill for developer tool sandboxing -- policy authoring burden is disproportionate to benefit [61].

### seccomp-bpf [63][64]

**Mechanism:** BPF programs filtering system calls. Process installs filter via `prctl(PR_SET_SECCOMP)` or `seccomp()` syscall. Inspects syscall numbers and raw register arguments [64].

**Actions:** ALLOW, KILL, ERRNO, TRAP, TRACE [64].

**Performance:** Nanoseconds per syscall. gVisor optimization work: removed up to 3.4 seconds from ABSL build (~3.6% of total runtime). Kernel JIT-compiles filters and caches results for "cacheable" syscalls [63].

**Limits:** Max 4,096 BPF instructions per filter. Max 32,768 total across stacked filters [64].

**Critical limitation:** Cannot filter by file paths or data in memory -- only raw syscall arguments (register values). This is why Landlock was created [64].

### Restricted Shells (rbash) [65][66]

**Mechanism:** bash started with `-r` or invoked as `rbash`. Disables: cd, setting/unsetting PATH/SHELL/ENV/BASH_ENV, commands containing `/`, output redirection [65].

**Bypass methods (extensively documented):**
1. SSH: `ssh user@host bash --noprofile` [65]
2. Text editors: `:!sh` in vim [65]
3. Pagers: `!sh` in less/more/man [65]
4. Languages: Python, Perl, Ruby can spawn unrestricted shells [65]
5. awk/expect: `awk 'BEGIN {system(...)}'` [65]
6. Wildcards: using `?` and `*` to reference binaries [65]
7. Environment variables: if PATH is writable [65]

**Assessment:** "trivially bypassed" [66]. Designed for limiting accidental misuse, not adversarial confinement.

### Linux Capabilities [67]

**Mechanism:** ~40 distinct capability units splitting root's monolithic privilege. Five sets per thread: Permitted, Effective, Inheritable, Bounding, Ambient [67].

**What it restricts:** Privileged operations (binding low ports, loading kernel modules, overriding file permissions, raw network access, system time changes). Does NOT restrict file path access or command execution [67].

**Tools:** `setcap`, `capsh`, `filecap`/`pscap` from `libcap-ng-utils` [67].

**Assessment:** Complementary but insufficient alone. Dropping all capabilities is a good baseline but doesn't replace path-based access control [67].

### Landlock LSM [68][69]

**Mechanism:** Stackable LSM enabling unprivileged processes to restrict their own access rights via three syscalls: `landlock_create_ruleset()`, `landlock_add_rule()`, `landlock_restrict_self()` [68].

**ABI evolution:**

| ABI | Kernel | Capabilities |
|-----|--------|-------------|
| 1 | 5.13 | Filesystem (execute, read/write files, read dirs, remove, create) |
| 2 | 5.19 | File refer (cross-directory rename/link) |
| 3 | 6.2 | Truncate |
| 4 | N/A | Network (TCP bind/connect to specific ports) |
| 5 | N/A | ioctl on devices |
| 6 | N/A | Scoping (abstract UNIX socket and signal restrictions) |

**Key properties:**
- No root required, no system-wide configuration [69]
- Restrictions inherited by child processes (like seccomp) [68]
- Restrictions can only be tightened, never loosened [68]
- Maximum 16 stacked layers [68]
- Available since kernel 5.13 [69]

**Performance:** Described as "less overhead than seccomp" for policy-based access control (est.) -- operates at LSM hook level, not syscall level [68].

**Relevance:** Most directly applicable tool for this use case. Enables process to restrict own filesystem access without root. Used by Codex CLI [21] and ai-jail [56].

### pledge/unveil (OpenBSD) [70][71][72]

**pledge:** Forces process into restricted operating mode. Promises: `stdio`, `rpath`, `wpath`, `cpath`, `inet`, `dns`, `proc`, `exec`, `settime`, etc. Violations: uncatchable SIGABRT. Subsequent calls can only reduce abilities [70].

**unveil:** Restricts filesystem visibility. Only unveiled paths accessible; `unveil(NULL, NULL)` locks view permanently. Flags: `rwxc` (read, write, execute, create) [71].

**Complementary:** pledge restricts syscall categories but not paths -- a pledged process with `rpath` could read SSH keys. unveil restricts which paths are visible [70][71].

**Linux port (Cosmopolitan Libc):** seccomp-bpf based. Limitations: no path-based filtering (seccomp can't inspect memory), x86-64 only, incompatible with glibc, EPERM instead of SIGABRT [72].

## Defense-in-Depth Model [73]

The established layering model for Linux security:

| Layer | Mechanism | Purpose |
|-------|-----------|---------|
| 1 | Capabilities | Remove privileged operations |
| 2 | seccomp-bpf | Filter dangerous syscalls |
| 3 | AppArmor/SELinux | Restrict file/network access |
| 4 | Landlock | Application-embedded restrictions |

seccomp is **voluntary** (process opts in); AppArmor/SELinux are **mandatory** (admin-loaded). PreToolUse hooks are analogous to seccomp/Landlock/pledge -- voluntary, application-embedded [73].

## Relevance to This Repo's Hooks

| Feature | PreToolUse hooks | Landlock | AppArmor | seccomp-bpf |
|---------|-----------------|----------|----------|-------------|
| Root required | No | No | Yes | No |
| Path filtering | Yes (regex) | Yes (hierarchy) | Yes (path-based) | No |
| Command filtering | Yes (regex) | No | Indirectly (exec rules) | No (syscall only) |
| Cross-platform | Yes | Linux 5.13+ | Linux | Linux |
| Enforcement level | Application | Kernel | Kernel | Kernel |
| Bypass via agent | No escape hatch | Monotonically decreasing | Requires root | Monotonically decreasing |
| Setup complexity | Low (Python script) | Low-Medium (3 syscalls) | Medium (profile authoring) | Medium (BPF programs) |

## Gaps and Limitations

1. Landlock performance claim ("less overhead than seccomp") from community discussion, not published benchmarks (est.)
2. CrackArmor (March 12, 2026) is very recent -- patch status may have evolved
3. All data gathered via search result summaries -- kernel documentation and papers not directly fetched
4. pledge Linux port limitations well-documented but implementation may have evolved
5. rbash bypass documentation is comprehensive but many sources are from penetration testing contexts
