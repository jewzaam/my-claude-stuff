# GWS CLI Mutation Blocking

Defense-in-depth blocking for the `gws` (Google Workspace CLI) tool, implemented as PreToolUse hook patterns in `scripts/block_commands.py`.

## Threat Model

- AI agents may invoke `gws` commands autonomously
- **Email egress is the primary threat** — `gws gmail +send` accepts arbitrary recipients with no restrictions at the CLI level
- Calendar, Chat, and any service that can communicate externally are secondary egress vectors
- Shared resources (Sheets, Drive) enable indirect data exfiltration to external collaborators
- Push notification subscriptions (Events API) create persistent data channels

## Security Architecture

Two independent layers enforce access control:

1. **OAuth scope enforcement** (server-side) — Google's API servers reject requests outside granted scopes. Login with `gws auth login --readonly` to restrict all services to read-only.
2. **CLI-level pattern blocking** (this implementation) — regex patterns in the PreToolUse hook block mutation commands before they execute, regardless of OAuth scopes.

Neither layer alone is sufficient. OAuth scopes can be re-granted; CLI blocking prevents the AI agent from even attempting mutations.

## Access Policy

| Service | Read | Write | Rationale |
|---------|------|-------|-----------|
| Docs | Yes | **No** | Batch payloads obscure scope; indirect exfil via shared docs |
| Slides | Yes | **No** | Same rationale as Docs |
| Sheets | Yes | **No** | Indirect exfil via shared sheets |
| Drive | Yes | **No** | File mutations + permission changes = exfil |
| Gmail | Yes | **NEVER** | Arbitrary recipient email = primary exfil vector |
| Calendar | Yes | **NEVER** | Meeting invites to external attendees |
| Chat | No | **NEVER** | All message egress blocked |
| Tasks | Yes | **No** | Write operations blocked |
| Keep | Yes | **No** | Write operations blocked |
| Forms | Yes | **No** | Write operations blocked |
| Meet | Yes | **No** | Space creation/modification blocked |
| Classroom | No | **No** | Entire service blocked |
| Events | No | **No** | Push notification subscriptions blocked |
| Workflow | Partial | Partial | Only egress helpers blocked (+file-announce, +email-to-task) |

## Blocked Patterns Reference

### Gmail (NEVER — all mutations)

| Pattern | Matches | Why Blocked |
|---------|---------|-------------|
| `gws gmail +send\|+reply\|+reply-all\|+forward\|+watch` | Helper commands for email send/reply/forward and watch setup | Direct email egress to arbitrary recipients |
| `gws gmail messages send\|import\|insert\|delete\|...` | API-level message mutations | Send, import, or manipulate email messages |
| `gws gmail drafts create\|send\|update\|delete` | Draft mutations | Drafts can be sent; create/update is a send precursor |
| `gws gmail labels create\|delete\|patch\|update` | Label mutations | Label manipulation can affect mail routing/filtering |
| `gws gmail settings ... create\|update\|delete\|patch` | Settings sub-resource mutations | Forwarding rules, filters, send-as aliases |
| `gws gmail watch\|stop` | Push notification control | Establishes persistent data channels |

**Allowed**: `messages list/get`, `labels list/get`, `drafts list/get`

### Calendar (NEVER — all mutations)

| Pattern | Matches | Why Blocked |
|---------|---------|-------------|
| `gws calendar +insert` | Helper to create events | External attendee invitations |
| `gws calendar events insert\|delete\|import\|move\|patch\|quickAdd\|update\|watch` | Event CRUD | Creating/modifying events with external attendees |
| `gws calendar acl insert\|delete\|patch\|update` | ACL mutations | Calendar sharing permissions |
| `gws calendar calendars insert\|delete\|patch\|update\|clear` | Calendar CRUD | Calendar creation/deletion |
| `gws calendar calendarList insert\|delete\|patch\|update` | Calendar list mutations | Subscription management |
| `gws calendar channels stop` | Channel management | Push notification control |

**Allowed**: `+agenda`, `events list/get/instances`, `calendarList list`

### Chat (NEVER — all egress)

| Pattern | Matches | Why Blocked |
|---------|---------|-------------|
| `gws chat +send` | Helper to send messages | Direct message egress |
| `gws chat spaces create\|setup\|patch\|delete\|completeImport` | Space management | Creating communication channels |
| `gws chat messages create\|delete\|patch\|update` | Message CRUD | Sending/modifying messages |
| `gws chat members create\|delete` | Membership mutations | Adding/removing space members |
| `gws chat customEmojis create\|delete` | Emoji mutations | Resource creation |

### Drive (No writes)

| Pattern | Matches | Why Blocked |
|---------|---------|-------------|
| `gws drive +upload` | File upload helper | Creates files accessible to collaborators |
| `gws drive files create\|copy\|delete\|update\|emptyTrash\|modifyLabels` | File CRUD | File mutations and trash management |
| `gws drive permissions create\|update\|delete` | Permission mutations | Sharing files with external users |
| `gws drive comments/replies create\|update\|delete` | Comment/reply mutations | Communication via file comments |
| `gws drive drives create\|delete\|update\|hide\|unhide` | Shared drive mutations | Drive management |
| `gws drive channels stop` | Channel management | Push notification control |

**Allowed**: `files list/get`, `+download`, `+export`, `permissions list`

### Sheets (No writes)

| Pattern | Matches | Why Blocked |
|---------|---------|-------------|
| `gws sheets +append` | Append helper | Writes data to shared sheets |
| `gws sheets spreadsheets create\|batchUpdate` | Spreadsheet mutations | Creating/modifying spreadsheets |
| `gws sheets values append\|update\|batchUpdate\|clear\|...` | Cell value mutations | Writing data to cells |
| `gws sheets sheets copyTo` | Sheet copy | Duplicates sheets (potential data exposure) |

**Allowed**: `+read`, `values get/batchGet`, `spreadsheets get`

### Tasks, Keep, Forms (No writes)

| Service | Blocked | Why |
|---------|---------|-----|
| Tasks | `tasks insert/delete/patch/update/clear/move`, `tasklists insert/delete/patch/update` | Write operations |
| Keep | `notes create/delete` | Write operations |
| Forms | `forms create/batchUpdate` | Write operations |

### Docs (No writes)

| Pattern | Matches | Why Blocked |
|---------|---------|-------------|
| `gws docs documents create\|batchUpdate` | Document creation and batch mutations | Batch payloads obscure scope; indirect exfil via shared docs |

**Allowed**: `documents get`

### Slides (No writes)

| Pattern | Matches | Why Blocked |
|---------|---------|-------------|
| `gws slides presentations create\|batchUpdate` | Presentation creation and batch mutations | Same rationale as Docs |

**Allowed**: `presentations get`

### Workflow (Egress helpers only)

| Pattern | Matches | Why Blocked |
|---------|---------|-------------|
| `gws workflow\|wf +file-announce` | File announcement helper | Sends notifications about files |
| `gws workflow\|wf +email-to-task` | Email-to-task helper | Creates tasks from emails (egress) |

**Allowed**: `+standup-report`, `+meeting-prep`, `+weekly-digest` (read-only aggregation)

### Events/Subscriptions

| Pattern | Matches | Why Blocked |
|---------|---------|-------------|
| `gws events +subscribe\|+renew` | Subscription helpers | Creates persistent push notification channels |
| `gws events subscriptions create\|patch\|delete` | Subscription API mutations | Push notification channel management |

### Classroom (Entire service blocked)

All `gws classroom` subcommands are blocked. No read or write access.

### Meet (Mutations blocked)

| Pattern | Matches | Why Blocked |
|---------|---------|-------------|
| `gws meet spaces create\|patch\|endActiveConference` | Space mutations | Creating/modifying meeting spaces |

## Network Egress Analysis

All hardcoded URLs in the gws CLI point exclusively to `*.googleapis.com`:

| Component | Destination |
|-----------|-------------|
| Discovery fetch | `www.googleapis.com` |
| API requests | `{service}.googleapis.com` |
| OAuth token exchange | `oauth2.googleapis.com` |
| Model Armor | `modelarmor.{region}.rep.googleapis.com` |

No non-Google endpoints exist in source. Discovery Document `rootUrl`/`baseUrl` fields are fetched over HTTPS from hardcoded `googleapis.com` URLs. Exploitation requires MITM with a trusted CA.

## Credential Security

- Credentials encrypted at rest with AES-256-GCM, unique 12-byte nonce per encryption
- Encryption key stored in OS keyring (primary) with encrypted file fallback
- Key material zeroed after use via `zeroize` crate
- Unix file permissions: 0600 for credential files, 0700 for directories
- OAuth redirect URI hardcoded to `http://localhost`
- `gws auth export` masks secrets by default (requires `--unmasked` for full output)

## Dependency Supply Chain

- 353 transitive dependencies, all from crates.io (zero git dependencies)
- TLS: rustls (pure Rust) with system root certificate validation
- Crypto: AES-256-GCM via RustCrypto, key derivation via `ring`
- Auth: `yup-oauth2` (Google-backed)
- No dependency phones home or includes telemetry

## Known Limitations

Same caveats as general command blocking (see [blocked-commands-reference.md](blocked-commands-reference.md)):

- **Regex-based** — can be bypassed with creative quoting, variable expansion, or indirect invocation
- **Single-command scope** — cannot track state across multiple commands (e.g., alias setup then invocation)
- **CLI layer only** — direct API calls via `curl` to googleapis.com are not caught by these patterns
- **Heredoc stripping** — commands inside heredoc bodies are intentionally not checked (avoids false positives)
- **No argument inspection** — patterns match command structure, not argument values (e.g., cannot distinguish internal vs external email recipients)

## See Also

- [blocked-commands-reference.md](blocked-commands-reference.md) — General command blocking reference
- [block-commands-design.md](block-commands-design.md) — Design decisions and architecture
