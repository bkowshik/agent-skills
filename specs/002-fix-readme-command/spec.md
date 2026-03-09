# Feature Specification: Fix README Install Command

**Feature Branch**: `002-fix-readme-command`
**Created**: 2026-03-09
**Status**: Draft
**Input**: User description: "Fix the command on README — add correct install command for skills"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Install skills from README instructions (Priority: P1)

A user discovers the git-skills repository and wants to install the squash-commits skill into their project. They copy the install command from the README, run it in their terminal, and the skill installs successfully on the first attempt.

**Why this priority**: The README is the primary entry point for new users. An incorrect or missing install command blocks adoption entirely.

**Independent Test**: Can be fully tested by copying the command from the README, running it in a terminal, and verifying the skill installs without errors.

**Acceptance Scenarios**:

1. **Given** a user reads the README, **When** they copy and run the install command, **Then** the skill installs successfully with `npx skills add bkowshik/git-skills`
2. **Given** a user reads the README, **When** they follow the instructions, **Then** they do not encounter "No valid skills found" or clone failures

---

### Edge Cases

- What happens when a user appends a trailing slash to the command? (The correct syntax has no trailing slash — the README should not include one)
- What happens when a user tries to install a specific skill by appending the skill name as a path segment? (The `npx skills add` command uses `owner/repo` format, not `owner/repo/skill-name`)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: README MUST include a working install command: `npx skills add bkowshik/git-skills`
- **FR-002**: README MUST show the install command in a clearly visible Installation section positioned before the Skills table
- **FR-003**: The install command MUST use `owner/repo` syntax without trailing slashes or subdirectory paths

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can install skills by copying a single command from the README and running it successfully on the first attempt
- **SC-002**: The README contains an Installation section visible before the Skills listing

## Assumptions

- The `npx skills` CLI tool is already published and available via npm
- The correct install syntax is `npx skills add <owner>/<repo>` (not `<owner>/<repo>/<skill-name>`)
- Users have Node.js/npm installed as a prerequisite
