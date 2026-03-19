# Block Commands — Research Findings

Raw research findings that informed the design of `scripts/block_commands.py`.

## Community Project Survey

### dcg (Destructive Command Guard)

- Regex-based approach matching our design
- Focuses on Unix commands: `rm -rf`, `mkfs`, `dd`, `shred`
- Uses simple string matching without preprocessing
- No Windows support
- Key insight: Community consensus that regex is "good enough" for safety nets

### claude-code-safety-net

- Reference implementation for Claude Code hooks
- Pattern: JSON stdin → pattern match → exit code 2 to block
- Covers git commands, sudo, rm
- Lacks: Windows commands, chain splitting, path normalization
- Our implementation extends this significantly

### sgasser / Mandalorian007 contributions

- GitHub issues requesting Windows command blocking
- Identified: `format`, `diskpart`, `rd /s`, `del /s` as priority Windows commands
- Pointed out PowerShell `Remove-Item -Recurse` as equivalent of `rm -rf`

### Trail of Bits configuration

- Security-focused approach emphasizing principle of least privilege
- Recommends blocking `sudo`, `su`, privilege escalation paths
- Notes that `eval`, `source`, and interpreter one-liners are impractical to block with regex
- Recommends documenting known limitations rather than attempting impossible coverage

## Windows Destructive Command Taxonomy

### Tier 1 — Direct Data Destruction
- `format [drive]:` — Formats entire disk volumes
- `diskpart` — Interactive disk partitioning (can delete volumes, clean disks)
- `rd /s` / `rmdir /s` — Recursive directory deletion
- `del /s` / `erase /s` — Recursive file deletion
- `cipher /w` — Wipes free space (destroys recoverable data)

### Tier 2 — System Configuration
- `bcdedit` — Boot Configuration Data editor (can make system unbootable)
- `sc delete` — Permanently removes Windows services
- `reg delete` — Deletes registry keys (can break system/applications)

### Tier 3 — PowerShell Equivalents
- `Remove-Item -Recurse` — PowerShell equivalent of `rm -rf`
- `Format-Volume` — PowerShell equivalent of `format`
- `Clear-Disk` — Wipes all data from a disk
- `Remove-Partition` — Removes disk partitions

### Tier 4 — Excluded (Reversible or Requires Elevation)
- `Stop-Service` / `Stop-Process` — Reversible, services can be restarted
- `net stop` — Requires admin elevation
- `Disable-NetAdapter` — Reversible, requires elevation

## PowerShell Constrained Language Mode (CLM) Reference

PowerShell CLM restricts available language features in security-sensitive environments:
- Blocks `Add-Type` (loading arbitrary .NET code)
- Blocks COM object creation
- Restricts available cmdlets

Relevant for understanding why we block PowerShell disk cmdlets independently — in CLM environments, these cmdlets may still be available while other dangerous operations are restricted.

JEA (Just Enough Administration) provides role-based cmdlet restrictions. Our hook operates at a different layer — blocking commands before they reach the shell, regardless of PowerShell's own restrictions.

## MSYS2 / Git Bash Path Conversion Rules

MSYS2 automatically converts Unix-style paths to Windows paths when calling native Windows executables:

| Input | Converted To | Context |
|-------|-------------|---------|
| `/c/Windows/System32/cmd.exe` | `C:\Windows\System32\cmd.exe` | MSYS path to Windows path |
| `/usr/bin/git` | `C:\Program Files\Git\usr\bin\git.exe` | Git Bash internal path |
| `C:\foo\bar` | `C:\foo\bar` | Already Windows, passed through |

**Impact on our patterns:**
- Must handle both `/c/Windows/...` and `C:/Windows/...` and `C:\Windows\...`
- Solution: Normalize all backslashes to forward slashes in preprocessing, then `_PATH` pattern handles all variants

**Edge case:** MSYS2's `MSYS2_ARG_CONV_EXCL` environment variable can disable path conversion. We don't need to handle this because normalization happens in our preprocessing, not in the shell.

## Regex vs AST vs Whitelisting Tradeoffs

### Regex (chosen approach)
- **Pro:** Zero dependencies, fast (<1ms per check), simple to maintain
- **Pro:** Community-proven pattern across multiple projects
- **Con:** Can be bypassed via variable expansion, aliases, encoding
- **Con:** No structural understanding of shell syntax

### AST Parsing (Oil Shell, tree-sitter-bash)
- **Pro:** Structurally correct — understands quoting, expansion, subshells
- **Pro:** Can detect commands inside `$(...)`, backticks, eval
- **Con:** Native dependency (tree-sitter) or Python dependency (Oil Shell)
- **Con:** Latency (~10-50ms per parse on complex commands)
- **Con:** Overkill for safety net use case

### Whitelisting (allow-list only)
- **Pro:** Most secure — only explicitly approved commands run
- **Con:** Impractical for Claude Code — the AI needs to run arbitrary build/test commands
- **Con:** Maintenance burden is inverted (every new tool needs approval)

### Decision
Regex with mitigations. The hook is a **safety net**, not a **sandbox**. It catches common destructive patterns to prevent accidents. Determined attackers (or sufficiently creative AI) can bypass regex — but that's acceptable because:
1. The user approves each Bash invocation
2. The hook catches the 95% case of accidental destruction
3. The remaining 5% requires intentional obfuscation

## Considered-But-Excluded Commands

### Too broad — would break legitimate workflows
- `python -c` / `python3 -c` — Breaks one-liner scripting, testing
- `node -e` / `ruby -e` / `perl -e` — Same issue across interpreters
- `eval` — Used legitimately in shell scripts constantly
- `source` / `.` — Used for environment setup
- `exec` — Used in shell scripts for process replacement
- `xargs` — Would block `find ... | xargs rm` but also `find ... | xargs grep`

### Already covered by sudo block
- `mount` / `umount` — Requires root
- `insmod` / `modprobe` / `rmmod` — Requires root
- `iptables` / `nftables` / `ufw` — Requires root
- `fdisk` / `parted` / `gdisk` — Requires root
- `lvm` / `pvcreate` / `vgcreate` / `lvcreate` — Requires root
- `systemctl` (dangerous operations) — Requires root for system services
- `useradd` / `userdel` / `usermod` — Requires root

### Already covered by Windows elevation
- `net stop` / `net user` — Requires admin elevation
- `wmic` — Deprecated, requires admin for destructive operations
- `sfc` / `DISM` — Requires admin elevation

### Non-destructive despite sounding dangerous
- `git revert` — Creates a new commit (non-destructive undo)
- `git cherry-pick` — Creates new commits
- `git merge` — Can be undone with `git reset` (which IS blocked)
- `kill` / `pkill` — Processes can be restarted (reversible)
- `truncate` — Could be destructive but extremely uncommon in AI workflows

### Impractical to match
- Commands via aliases (`alias rm='rm -rf'`)
- Commands via shell functions
- Commands via `busybox` multi-call binary
- Commands via `env -i /bin/sh -c "..."` wrapper chains
- Commands encoded in base64/hex and decoded at runtime
