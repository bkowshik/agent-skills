# Feature Specification: Force Push with Confirmation in Squash Skill

**Feature Branch**: `006-force-push-confirm`
**Created**: 2026-03-15
**Status**: Draft
**Input**: User description: "I want the squash skill to also do force-with-lease with user confirmation instead of just printing it as the next step so that the user does not have to copy and paste the command and instead just confirm."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Automatic Force Push After Squash (Priority: P1)

A developer squashes commits on a branch that has already been pushed to a remote. After the squash completes successfully, instead of being told to manually run `git push --force-with-lease`, the skill asks them to confirm the force push and executes it on their behalf.

**Why this priority**: This is the core request. The current workflow breaks flow by requiring the user to copy-paste a command after squashing. Automating it with confirmation keeps the user in the skill's guided experience.

**Independent Test**: Can be fully tested by squashing commits on a pushed branch and verifying the skill offers to force-push and executes it upon confirmation.

**Acceptance Scenarios**:

1. **Given** a branch with multiple commits that has been pushed to a remote, **When** the user runs the squash skill and confirms the squash, **Then** after the squash completes, the skill asks whether they want to force-push the rewritten branch to the remote.
2. **Given** the user confirms the force push, **When** the skill executes the push, **Then** `git push --force-with-lease` runs against the correct remote and branch, and the result is displayed to the user.
3. **Given** the user declines the force push, **When** prompted, **Then** the skill completes without pushing and shows the manual command as a reference, preserving current behavior.

---

### User Story 2 - Skip Force Push Prompt for Unpushed Branches (Priority: P1)

A developer squashes commits on a branch that has never been pushed. The skill should not prompt for force-push at all since it is unnecessary.

**Why this priority**: Equally critical as Story 1 — prompting to force-push an unpushed branch would be confusing and incorrect.

**Independent Test**: Can be tested by squashing commits on a local-only branch and verifying no force-push prompt appears.

**Acceptance Scenarios**:

1. **Given** a branch with multiple commits that has NOT been pushed to a remote, **When** the user completes the squash, **Then** the skill does not ask about force-pushing and completes normally.

---

### User Story 3 - Force Push Failure Handling (Priority: P2)

A developer confirms the force push but it fails (e.g., network error, remote rejected the push due to branch protection rules, or another collaborator pushed in the meantime causing `--force-with-lease` to reject). The skill should display the error clearly and inform the user that their local squash is still intact.

**Why this priority**: Important for robustness but less common than the happy path. Users need to know their local work is safe even if the push fails.

**Independent Test**: Can be tested by simulating a push failure (e.g., protected branch) and verifying the error message and recovery guidance.

**Acceptance Scenarios**:

1. **Given** the user confirms force push after squashing, **When** `git push --force-with-lease` fails, **Then** the skill displays the error output, confirms the local squash is intact, and provides the manual push command for retry.

---

### Edge Cases

- What happens when the remote branch was deleted between squash and push? The push should fail with a clear error, and the user should be informed their local squash is intact.
- What happens when `--force-with-lease` is rejected because someone else pushed to the branch? The error should be displayed with guidance that someone else has pushed new commits.
- What happens when there is no remote configured at all? The skill should skip the force-push prompt entirely, same as unpushed branches.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: After a successful squash on a pushed branch, the skill MUST prompt the user to confirm whether they want to force-push the rewritten history to the remote.
- **FR-002**: Upon user confirmation, the skill MUST execute `git push --force-with-lease` targeting the current branch's upstream remote and branch.
- **FR-003**: If the user declines the force push, the skill MUST skip pushing and display the manual command as a reference (preserving current behavior).
- **FR-004**: If the branch has not been pushed (no upstream), the skill MUST NOT prompt for force-push.
- **FR-005**: If the force push fails, the skill MUST display the error output, reassure the user that the local squash is intact, and provide the manual command for retry.
- **FR-006**: The force-push confirmation MUST be a separate prompt from the squash confirmation, occurring only after the squash has completed successfully.
- **FR-007**: The force-push warning about collaborators seeing diverged history MUST still be displayed before the confirmation prompt.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users who squash a pushed branch can complete the entire squash-and-push workflow without leaving the skill's guided experience.
- **SC-002**: 100% of force pushes require explicit user confirmation — no automatic pushing without consent.
- **SC-003**: Users on unpushed branches experience no change in workflow — no unnecessary prompts are introduced.
- **SC-004**: When force push fails, users understand that their local work is safe and know how to retry.

## Assumptions

- The skill already correctly detects whether a branch has been pushed via the `HAS_UPSTREAM` flag from the helper script.
- The remote name and branch can be determined from git's upstream tracking configuration.
- `--force-with-lease` is the appropriate push strategy (it prevents overwriting others' work, unlike `--force`).
- The force-push step modifies only the SKILL.md workflow instructions, not the helper bash script (the script handles squashing, not pushing).
