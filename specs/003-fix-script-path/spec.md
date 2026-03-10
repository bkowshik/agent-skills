# Feature Specification: Fix Script Path Resolution in Squash-Commits Skill

**Feature Branch**: `003-fix-script-path`
**Created**: 2026-03-10
**Status**: Draft
**Input**: User description: "Fix squash-commits skill script path resolution so it finds the helper script on the first attempt"

## Clarifications

### Session 2026-03-10

- Q: Which canonical path prefix should SKILL.md use for script references? → A: Use a path variable/placeholder (`{{SKILL_DIR}}`) that each LLM resolves at runtime, keeping skills LLM-agnostic.
- Q: What should the placeholder variable name and format be? → A: `{{SKILL_DIR}}` — mustache-style template token, replaced by the skill loader at read time. Avoids collision with shell variables.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Skill Finds Script on First Attempt (Priority: P1)

A developer invokes the `/squash-commits` skill from the project root. The skill loader resolves the `{{SKILL_DIR}}` placeholder to the actual skill directory path, then locates the helper script (`squash.sh`) on the first attempt without path resolution failures.

**Why this priority**: This is the core bug — the skill currently fails twice before finding the script, wasting time and producing confusing error output.

**Independent Test**: Invoke `/squash-commits` on a branch with multiple commits and verify the first command executed against `squash.sh` succeeds without "no such file or directory" errors.

**Acceptance Scenarios**:

1. **Given** a user is on a feature branch with multiple commits, **When** they invoke `/squash-commits`, **Then** the skill locates and runs the helper script on the first attempt with no path errors.
2. **Given** a user is on a feature branch with multiple commits, **When** they invoke `/squash-commits`, **Then** no "no such file or directory" errors appear in the output before the script runs successfully.

---

### User Story 2 - SKILL.md Uses Portable Path Placeholders (Priority: P1)

The SKILL.md file for squash-commits uses `{{SKILL_DIR}}` placeholders instead of hardcoded paths, so any LLM's skill loader can resolve the placeholder to the correct filesystem path at read time.

**Why this priority**: The root cause of the bug — SKILL.md currently references `scripts/squash.sh` (relative to the skill directory) which doesn't resolve from the project root. Using `{{SKILL_DIR}}` makes the path portable across different LLM tools (Claude Code, Cursor, Copilot, etc.) that may discover skills via different directory structures.

**Independent Test**: Read the SKILL.md file and verify all script path references use the `{{SKILL_DIR}}` placeholder, and that resolving the placeholder produces a valid path from the project root.

**Acceptance Scenarios**:

1. **Given** the SKILL.md file, **When** an LLM's skill loader resolves `{{SKILL_DIR}}` to the skill's actual directory path, **Then** all script references resolve to valid filesystem paths.
2. **Given** the SKILL.md file, **When** reviewing all code blocks and inline references to `squash.sh`, **Then** every reference uses `{{SKILL_DIR}}/scripts/squash.sh` format.

### Edge Cases

- What happens if an LLM's skill loader does not support `{{SKILL_DIR}}` resolution? The placeholder appears literally in the path, causing a clear error that indicates the loader needs updating — preferable to a silently wrong relative path.
- What happens if the skill is invoked from a subdirectory? The resolved `{{SKILL_DIR}}` should produce an absolute or project-root-relative path, so execution location does not matter.
- What happens if the project directory structure changes (e.g., `.agents/` is renamed)? Only the skill loader's resolution mapping needs updating — SKILL.md itself remains unchanged.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: SKILL.md MUST reference the helper script using `{{SKILL_DIR}}/scripts/squash.sh` in all code blocks and inline references.
- **FR-002**: All command examples in SKILL.md (dry-run, execution, base-branch variants) MUST use the `{{SKILL_DIR}}` placeholder for the skill directory portion of the path.
- **FR-003**: The helper script itself MUST NOT be modified — only the path references in SKILL.md need updating.
- **FR-004**: The `{{SKILL_DIR}}` placeholder MUST be the only mechanism used for path resolution — no hardcoded absolute or relative paths to the script.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The `/squash-commits` skill locates and executes the helper script on the first attempt, with zero "file not found" errors.
- **SC-002**: 100% of script path references in SKILL.md use the `{{SKILL_DIR}}` placeholder instead of hardcoded paths.
- **SC-003**: All code block examples in SKILL.md use `{{SKILL_DIR}}/scripts/squash.sh` and resolve correctly when the placeholder is substituted with the actual skill directory path.
