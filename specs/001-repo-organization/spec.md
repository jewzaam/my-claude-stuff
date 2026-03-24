# Feature Specification: Repository Organization Strategy

**Feature Branch**: `001-repo-organization`
**Created**: 2026-03-24
**Status**: Draft
**Input**: User description: "Repository organization: should this mono-repo be broken up by domain (e.g., GWS tooling separate from other concerns) or reorganized within the repo? Evaluate grouping strategies for the codebase."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Evaluate Current Domain Boundaries (Priority: P1)

As the repository maintainer, I want a clear inventory of the distinct domains currently in this repo so I can make an informed decision about whether to split, reorganize internally, or keep the status quo.

**Why this priority**: No organizational decision can be made without first understanding what domains exist and how they relate to each other.

**Independent Test**: Can be validated by producing a domain inventory document that maps every script, config, and test to a domain and identifies coupling between domains.

**Acceptance Scenarios**:

1. **Given** the current repo contents, **When** I review the domain inventory, **Then** I can identify each distinct domain (e.g., Claude Code configuration management, GWS discovery tooling, session/prompt tracking, notification utilities) and its boundaries
2. **Given** the domain inventory, **When** I examine cross-domain dependencies, **Then** I can see which domains share code, config, or test infrastructure

---

### User Story 2 - Choose an Organization Strategy (Priority: P2)

As the repository maintainer, I want to evaluate concrete organization strategies (mono-repo with internal grouping, multi-repo split, or hybrid) against criteria that matter to me so I can pick the right approach.

**Why this priority**: The strategy decision depends on the domain inventory (P1) and directly determines what restructuring work follows.

**Independent Test**: Can be validated by producing a decision matrix comparing strategies against evaluation criteria, with a recommended option and rationale.

**Acceptance Scenarios**:

1. **Given** the domain inventory, **When** I evaluate each strategy, **Then** I can see tradeoffs for maintainability, discoverability, deployment independence, and shared infrastructure reuse
2. **Given** the evaluation, **When** I select a strategy, **Then** the decision and rationale are documented for future reference

---

### User Story 3 - Execute the Reorganization (Priority: P3)

As the repository maintainer, I want a migration plan that restructures the codebase according to the chosen strategy without breaking existing functionality.

**Why this priority**: Execution follows the decision. This is the largest effort and depends on both P1 and P2.

**Independent Test**: Can be validated by executing the migration plan and confirming all tests pass, all scripts remain functional, and the reconcile workflow still works correctly.

**Acceptance Scenarios**:

1. **Given** the chosen strategy, **When** the migration plan is executed, **Then** all existing tests pass in the new structure
2. **Given** the new structure, **When** I run the reconcile workflow, **Then** configuration deployment still works correctly
3. **Given** the new structure, **When** a new contributor looks at the repo, **Then** they can understand the organization and find relevant code within their domain

---

### Edge Cases

- What happens to shared utilities (e.g., `config.py`, `notify.py`) that serve multiple domains?
- How are cross-domain test fixtures and conftest.py handled if domains are separated?
- What happens to the Makefile targets if the repo splits into multiple repos?
- How does the `.specify/` spec-kit infrastructure travel with a split?
- What happens to git history if repos are split?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The domain inventory MUST identify every top-level module, script, and configuration file and assign it to a domain
- **FR-002**: The domain inventory MUST identify cross-domain dependencies (shared imports, shared config, shared test infrastructure)
- **FR-003**: The strategy evaluation MUST compare at least three approaches: keep as-is with better internal grouping, full multi-repo split, and a hybrid approach
- **FR-004**: The strategy evaluation MUST assess each approach against: maintainability, discoverability, deployment independence, CI/CD complexity, and shared infrastructure reuse
- **FR-005**: The chosen strategy MUST preserve all existing functionality without regression
- **FR-006**: The migration plan MUST include a rollback approach

### Key Entities

- **Domain**: A cohesive grouping of related scripts, configs, and tests that serve a single concern (e.g., "Claude Code configuration management", "GWS discovery tooling")
- **Cross-Domain Dependency**: A shared module, config file, or test fixture used by more than one domain
- **Organization Strategy**: A concrete approach to structuring the codebase (mono-repo grouped, multi-repo, hybrid)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Every file in the repository is assigned to exactly one domain in the inventory
- **SC-002**: All cross-domain dependencies are identified and documented
- **SC-003**: The chosen strategy reduces time to locate relevant code for a given task compared to the current flat structure
- **SC-004**: All existing tests pass after reorganization with no test modifications beyond import path changes
- **SC-005**: The decision rationale is documented so future contributors understand why this structure was chosen

## Assumptions

- The current repository is small enough that a reorganization is feasible without specialized tooling (e.g., preserving full git history per-file is not a hard requirement)
- The primary user of this repo is a single maintainer, so coordination overhead of multi-repo is a real cost even without a team
- GWS tooling (`discover_gws_help.py`) is a distinct domain from Claude Code configuration management (`reconcile.py`, `claude/`)
- Session tracking, notifications, and prompt logging may or may not constitute their own domain vs. being grouped under "Claude Code operational tooling"
- Spec-kit infrastructure (`.specify/`) stays with whichever repo is considered the "primary" or gets duplicated per repo if split
