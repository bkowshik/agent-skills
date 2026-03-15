# Feature Specification: Rename Repository from git-skills to agent-skills

**Feature Branch**: `005-rename-repo`
**Created**: 2026-03-15
**Status**: Draft
**Input**: User description: "Rename the repository as well as contents inside the repository from git-skills to agent-skills instead."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Update all in-repo references from git-skills to agent-skills (Priority: P1)

A repository maintainer wants to rename their project from "git-skills" to "agent-skills" to better reflect its broader scope (not just git-related skills). All file contents, documentation, install commands, and project headings within the repository must consistently use the new name so that users and contributors see a cohesive identity.

**Why this priority**: Internal consistency is the foundation — if file contents still say "git-skills" after the rename, users will be confused and install commands will break once the GitHub repo is renamed.

**Independent Test**: Search the entire repository for the string "git-skills" after the rename. Zero matches should appear in user-facing files (README, SKILL.md files, skill READMEs, CLAUDE.md, constitution). Historical spec documents from prior features are excluded since they describe past decisions accurately.

**Acceptance Scenarios**:

1. **Given** the repository contains references to "git-skills" in README.md, CLAUDE.md, skill READMEs, and the constitution, **When** the rename is applied, **Then** all those references read "agent-skills" instead.
2. **Given** install commands reference `bkowshik/git-skills`, **When** the rename is applied, **Then** install commands reference `bkowshik/agent-skills`.
3. **Given** the repository heading says "# git-skills", **When** the rename is applied, **Then** the heading says "# agent-skills".

---

### User Story 2 - Preserve historical accuracy in past specs (Priority: P2)

Past feature specs (001, 002, 003) document decisions that were made when the repo was named "git-skills." These historical references should remain unchanged so that the project history remains accurate and traceable.

**Why this priority**: Changing historical documents would misrepresent past decisions. However, this is lower priority than the actual rename since it's about what *not* to change.

**Independent Test**: After the rename, review specs/001-*, specs/002-*, and specs/003-* directories. All original "git-skills" references in those files should remain untouched.

**Acceptance Scenarios**:

1. **Given** spec files exist for features 001, 002, and 003, **When** the rename is applied, **Then** those spec files are not modified.

---

### Edge Cases

- What happens if a file contains both the old repo name as a reference and as part of a longer string (e.g., "git-skills-extra")? Only exact "git-skills" references should be renamed.
- What happens with the skills-lock.json file if it contains repository references? It should be updated if it references the repo name.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: README.md MUST use "agent-skills" as the project name in the heading and description.
- **FR-002**: Install commands across all files MUST reference `bkowshik/agent-skills` instead of `bkowshik/git-skills`.
- **FR-003**: CLAUDE.md MUST use "agent-skills" in its heading and any project references.
- **FR-004**: The `.specify/memory/constitution.md` MUST use "agent-skills" in its heading.
- **FR-005**: All skill README files (e.g., `skills/squash-commits/README.md`, `skills/learning-log/README.md`) MUST reference `bkowshik/agent-skills` in install commands.
- **FR-006**: Historical spec files (specs/001-*, specs/002-*, specs/003-*) MUST NOT be modified.
- **FR-007**: The `skills-lock.json` file MUST be updated if it contains any "git-skills" references.

## Assumptions

- The GitHub repository rename (in GitHub settings) is a separate manual step performed by the user outside this feature's scope. This feature only covers in-repo file content changes.
- The `specs/004-spec-kit-worktree` directory, if it exists, should follow the same rule as other historical specs and not be modified unless it contains user-facing install commands.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Zero occurrences of "git-skills" in user-facing files (README.md, CLAUDE.md, skill READMEs, constitution) after the rename is complete.
- **SC-002**: All install commands in the repository work correctly when the GitHub repo is renamed to `agent-skills`.
- **SC-003**: 100% of historical spec files (features 001-003) remain unmodified.
