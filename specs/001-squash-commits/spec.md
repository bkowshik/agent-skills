# Feature Specification: Squash Commits

**Feature Branch**: `001-squash-commits`
**Created**: 2026-03-09
**Status**: Draft
**Input**: User description: "Git skill which when run on a git branch will combine all commits into one commit and uses the individual commit messages to form a single commit message. Branches are clean, just one commit instead of multiple small commits."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Squash all branch commits into one (Priority: P1)

A developer has been working on a feature branch with multiple small commits (WIP saves, fixes, iterations). Before merging, they want to collapse all branch commits into a single clean commit. The skill identifies which commits belong to the branch (diverged from the base branch), collects their messages, and produces one commit with a consolidated message.

**Why this priority**: This is the entire purpose of the skill. Without this, there is no skill.

**Independent Test**: Create a branch with 3+ commits off `main`, run the skill, verify the branch now has exactly one commit ahead of `main` with a coherent summary capturing the intent of all original commits.

**Acceptance Scenarios**:

1. **Given** a feature branch with 5 commits ahead of `main`, **When** the user runs the skill, **Then** the branch has exactly 1 commit ahead of `main` and the commit message is a coherent summary capturing the intent of all 5 original commits.
2. **Given** a feature branch with 1 commit ahead of `main`, **When** the user runs the skill, **Then** the skill informs the user there is nothing to squash and makes no changes.
3. **Given** a feature branch with commits ahead of `main`, **When** the user runs the skill, **Then** the working tree state (files, content) is identical before and after squashing.

---

### User Story 2 - Preview before squashing (Priority: P2)

A developer wants to see what the squash will do before it happens — which commits will be combined, what the consolidated message will look like, and which base branch is being used. This gives them confidence before a destructive operation.

**Why this priority**: Squashing rewrites history, which is destructive. Previewing reduces the risk of mistakes and aligns with the safety-first value from the constitution.

**Independent Test**: Run the skill on a branch with multiple commits, verify it shows the list of commits and the proposed consolidated message, and confirm no changes are made until the user approves.

**Acceptance Scenarios**:

1. **Given** a feature branch with 4 commits ahead of `main`, **When** the user triggers the skill, **Then** the skill displays all 4 commit messages and the proposed consolidated message without modifying any state.
2. **Given** the preview is shown, **When** the user confirms, **Then** the squash proceeds. **When** the user declines, **Then** no changes are made.

---

### User Story 3 - Handle non-standard base branches (Priority: P3)

A developer is working on a branch that was created off `develop` or `release/v2` instead of `main`. The skill detects the correct base branch automatically, or allows the user to specify it.

**Why this priority**: Most workflows use `main`, but teams that use `develop` or release branches need this to work too. It broadens the skill's usefulness without changing the core behavior.

**Independent Test**: Create a branch off `develop` with 3 commits, run the skill, verify it correctly identifies `develop` as the base and squashes only the 3 branch commits.

**Acceptance Scenarios**:

1. **Given** a branch created off `develop` with 3 commits, **When** the user runs the skill, **Then** the skill detects `develop` as the base branch and squashes only the 3 commits.
2. **Given** the skill cannot determine the base branch, **When** the user runs the skill, **Then** the skill asks the user to specify the base branch before proceeding.

---

### Edge Cases

- What happens when the branch has merge commits from pulling the base branch? The skill warns about merge commits and asks the user to confirm before proceeding.
- What happens when the working tree is dirty (uncommitted changes)? The skill refuses to squash and tells the user to commit or stash first, because a reset with dirty state can lose work.
- What happens when the branch has diverged from the base (base has new commits)? The skill squashes only the branch's own commits; it does not rebase onto the updated base.
- What happens on a detached HEAD? The skill refuses and explains that squashing requires a branch.
- What happens when the branch has already been pushed to a remote? The skill warns that a force-push will be needed after squashing and asks the user to confirm before proceeding.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The skill identifies all commits on the current branch that are ahead of the base branch.
- **FR-002**: The skill combines all identified commits into a single commit whose tree (file state) is identical to the original branch tip.
- **FR-003**: The consolidated commit message is a single coherent message synthesized from all original commit messages — not a mechanical list, but a meaningful summary that captures the intent of the combined changes. Git trailers (e.g., `Co-authored-by:`, `Signed-off-by:`) from all original commits are collected, deduplicated, and appended to the consolidated message.
- **FR-004**: The skill shows a preview of the squash (commits to be combined, proposed message) and waits for user confirmation before executing.
- **FR-005**: The skill creates a backup ref before squashing so the original history can be recovered.
- **FR-006**: The skill detects the base branch automatically by finding the merge-base with common default branches (`main`, `master`, `develop`), or asks the user when ambiguous.
- **FR-007**: The skill refuses to run when the working tree is dirty, on a detached HEAD, or when there is only one commit ahead of the base.
- **FR-008**: When the branch has already been pushed to a remote, the skill warns that a force-push will be required after squashing and asks for confirmation before proceeding.

### Key Entities

- **Branch commits**: The set of commits between the merge-base of the current branch and base branch, and the current branch tip. These are the commits to be squashed.
- **Consolidated message**: A single coherent commit message synthesized from all branch commit messages, capturing the overall intent rather than listing individual commits.
- **Backup ref**: A git ref pointing to the original branch tip before squashing, enabling recovery.

## Clarifications

### Session 2026-03-09

- Q: What happens when the branch has already been pushed to a remote? → A: Warn that a force-push will be needed, ask for confirmation before squashing.
- Q: How should the consolidated commit message be formatted? → A: A single coherent message synthesized from the individual commits, not a mechanical list.
- Q: Should git trailers (Co-authored-by, Signed-off-by) be preserved? → A: Yes, collect and deduplicate trailers from all commits and append to the consolidated message.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: After squashing, the branch has exactly one commit ahead of the base branch.
- **SC-002**: The file state (tree) of the branch tip is identical before and after squashing — no content is lost or changed.
- **SC-003**: The consolidated commit message accurately captures the intent of all original commits as a single coherent summary.
- **SC-004**: The original branch tip is recoverable via the backup ref.
- **SC-005**: The skill completes the squash operation in under 5 seconds for branches with up to 50 commits.
