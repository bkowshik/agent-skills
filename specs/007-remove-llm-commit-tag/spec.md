# Feature Specification: Remove LLM Attribution from Squashed Commit Messages

**Feature Branch**: `007-remove-llm-commit-tag`
**Created**: 2026-03-16
**Status**: Draft
**Input**: User description: "I don't want the LLM to add its name into the commit message created to summarize the individual commit messages."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Clean Squashed Commit Message (Priority: P1)

As a developer using the squash-commits skill, I want the final squashed commit message to contain only the synthesized summary of my work — without any LLM attribution tag (such as a "Co-Authored-By" line identifying the AI tool). The commit history should look like it was authored entirely by me, since the LLM is a tool I used, not a co-author.

**Why this priority**: This is the core ask. The LLM attribution line clutters commit messages and misrepresents the authorship of the work. The developer wrote the code; the LLM merely helped combine commit messages.

**Independent Test**: Can be fully tested by running the squash-commits skill on a branch with multiple commits and verifying the resulting commit message contains no LLM attribution lines.

**Acceptance Scenarios**:

1. **Given** a branch with multiple commits, **When** the user runs the squash-commits skill, **Then** the resulting single commit message contains only the synthesized summary and any original human-authored trailers — no LLM-identifying Co-Authored-By or similar attribution line is present.
2. **Given** a branch with commits that already contain human Co-Authored-By trailers, **When** the user runs the squash-commits skill, **Then** those original human trailers are preserved, but no new LLM attribution trailer is added.

---

### User Story 2 - Preserve Existing Human Trailers (Priority: P2)

As a developer working on a collaborative project, I want any existing human-authored trailers (Co-authored-by, Signed-off-by) from the original commits to still be preserved in the squashed commit, even though the LLM's own attribution is removed.

**Why this priority**: Maintaining proper human attribution and compliance trailers is important for collaborative projects and audit trails. This must not be broken by removing LLM attribution.

**Independent Test**: Can be tested by creating a branch with commits containing human Co-authored-by and Signed-off-by trailers, running squash-commits, and verifying those trailers appear in the final commit.

**Acceptance Scenarios**:

1. **Given** a branch with commits containing human "Co-authored-by: Jane Doe <jane@example.com>" trailers, **When** the user runs squash-commits, **Then** the squashed commit preserves "Co-authored-by: Jane Doe <jane@example.com>" in its message.
2. **Given** a branch with commits containing "Signed-off-by" trailers, **When** the user runs squash-commits, **Then** the squashed commit preserves those Signed-off-by trailers.

---

### Edge Cases

- What happens when the only trailers in the original commits are LLM-attributed Co-Authored-By lines? The squashed commit should have no trailers at all.
- What happens when a human collaborator's name coincidentally matches an LLM tool name? Only well-known LLM attribution patterns should be excluded (e.g., lines containing `noreply@anthropic.com` or similar bot email patterns), not arbitrary human names.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The squash-commits skill MUST NOT add any LLM attribution trailer (e.g., "Co-Authored-By: Claude...") to the synthesized commit message.
- **FR-002**: The squash-commits skill MUST continue to preserve human-authored trailers (Co-authored-by, Signed-off-by) from the original commits being squashed.
- **FR-003**: The squash-commits skill MUST filter out any existing LLM attribution trailers found in the original commits before appending trailers to the squashed commit message.
- **FR-004**: The skill instructions MUST explicitly tell the agent not to append its own identity or attribution to the commit message.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of squashed commits produced by the skill contain zero LLM attribution lines in the commit message.
- **SC-002**: 100% of human-authored trailers from original commits are preserved in the squashed commit message.
- **SC-003**: The squashed commit message reads as a clean, human-authored summary with no tool attribution artifacts.

## Assumptions

- "LLM attribution" refers specifically to Co-Authored-By (or similar) lines that identify an AI tool as a co-author, such as lines containing `noreply@anthropic.com` or AI model names like "Claude", "GPT", etc.
- The squash.sh helper script already extracts trailers from original commits; the filtering of LLM trailers can happen either in the script or in the skill instructions.
- The agent's default behavior of adding its own Co-Authored-By line can be overridden by explicit instructions in the SKILL.md file.
