# Feature Specification: Review PR Comments

**Feature Branch**: `009-review-pr-comments`
**Created**: 2026-03-30
**Status**: Draft
**Input**: User description: "You are acting as a Senior Member of Technical Staff reviewing this Pull Request. Review all comments carefully. For each comment: Determine if it requires a valid change, a suggestion, or something that can reasonably be pushed back. For valid changes, update the code directly. Use concise, descriptive commit messages without including your name or any AI references. For suggestions that can be pushed back, provide a professional rationale and propose alternatives if appropriate. After addressing all comments, draft a professional PR comment summarizing: What changes were made for each comment, Which recommendations were not incorporated and why, Any follow-up or next steps. Update the Pull Request with the revised code and post the PR comment. Ensure the PR comment is clear, actionable, and reflects the perspective of a Senior Member of Technical Staff."

> **Note**: The original input mentions a top-level summary PR comment. Per clarification (see [Clarifications](#clarifications) session 2026-03-30), the skill posts **inline replies only** — no top-level summary comment.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Triage and Address PR Review Comments (Priority: P1)

A developer has received review comments on their Pull Request and wants to efficiently process all feedback. They invoke the skill, which reads all unresolved PR comments, classifies each as a required change, a suggestion, or something to push back on, then makes code changes for valid items and prepares rationale for items being declined.

**Why this priority**: This is the core value proposition — turning PR review comments into concrete actions (code changes or reasoned pushback) without the developer manually processing each one.

**Independent Test**: Can be fully tested by running the skill against a PR with multiple review comments of varying types (nits, bugs, style suggestions, scope creep) and verifying that each comment is correctly classified and the appropriate action is taken.

**Acceptance Scenarios**:

1. **Given** a PR with 5 unresolved review comments (mix of bug fixes, style suggestions, and scope creep), **When** the user invokes the skill, **Then** each comment is classified as "required change", "suggestion", or "pushback" and the classification is shown to the user before any action is taken.
2. **Given** a comment that identifies a genuine bug, **When** the skill processes it, **Then** the code is updated to fix the bug with a concise, descriptive commit message that contains no AI attribution.
3. **Given** a comment that suggests an optional style change, **When** the skill processes it, **Then** either the change is made or a professional rationale is provided for why it was not incorporated.
4. **Given** a comment requesting out-of-scope work, **When** the skill processes it, **Then** a professional pushback rationale is drafted with an alternative or follow-up suggestion.

---

### User Story 2 - Post Inline Replies to Each Comment Thread (Priority: P1)

After all comments have been addressed (via code changes or pushback rationale), the skill posts an inline reply directly on each reviewer's comment thread. Each reply communicates the action taken — what was changed, why a suggestion was declined, or what follow-up is planned. No top-level summary comment is posted; reviewers are notified through their own threads.

**Why this priority**: Inline replies are essential for closing the review loop — each reviewer gets notified directly on their thread and can see the response without cross-referencing a separate summary.

**Independent Test**: Can be tested by verifying that each review comment thread receives an inline reply with the action taken and that no top-level summary comment is posted.

**Acceptance Scenarios**:

1. **Given** the skill has processed all review comments, **When** replies are generated, **Then** each comment thread receives an inline reply describing the action taken (code changed, suggestion declined with rationale, or follow-up noted).
2. **Given** the replies are ready, **When** the user confirms, **Then** each reply is posted to its respective comment thread via the GitHub CLI.
3. **Given** a comment was declined, **When** the inline reply is posted, **Then** it includes a professional rationale and, where appropriate, an alternative suggestion or a follow-up issue reference.

---

### User Story 3 - Preview and Confirm Before Committing (Priority: P2)

Before making any code changes or posting the summary comment, the user is shown a preview of all proposed actions — which comments will result in code changes, which will be pushed back, and a draft of the summary comment. The user can approve, modify, or skip individual items.

**Why this priority**: Giving the user control before irreversible actions (commits, PR comments) ensures the skill acts as an assistant, not an autonomous actor.

**Independent Test**: Can be tested by verifying the skill pauses for user confirmation before each commit and before posting the PR comment.

**Acceptance Scenarios**:

1. **Given** the skill has classified all comments, **When** it presents the action plan, **Then** the user sees a list of each comment, its classification, and the proposed action.
2. **Given** the user disagrees with a classification, **When** they override it, **Then** the skill adjusts its action for that comment accordingly.
3. **Given** the user approves the plan, **When** code changes are committed, **Then** each commit has a concise, descriptive message with no AI attribution tags.

---

### Edge Cases

- What happens when the PR has no unresolved comments? The skill reports "No unresolved comments found" and exits gracefully.
- What happens when a comment references code that has been deleted or moved since the review? The skill flags the comment as "stale" and asks the user how to proceed.
- What happens when the user lacks push access to the PR branch? The skill detects this early and informs the user.
- What happens when a comment is a general PR-level issue comment (not an inline review comment)? The skill ignores it — only inline review comments from formal code reviews are in scope.
- What happens when the GitHub CLI is not authenticated or not installed? The skill detects this and provides setup instructions.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST fetch all inline review comments (from formal code reviews) from a specified PR using the GitHub CLI. Top-level issue comments are out of scope.
- **FR-002**: System MUST classify each comment into one of three categories: "required change" (bug, correctness issue), "suggestion" (style, improvement), or "pushback" (out of scope, disagree).
- **FR-003**: System MUST present the classification of all comments to the user for review before taking action.
- **FR-004**: For comments classified as "required change", the system MUST update the relevant code and create one dedicated commit per comment with a concise, descriptive message.
- **FR-005**: Commit messages MUST NOT contain AI attribution, the user's name as author tag, or any auto-generated labels.
- **FR-006**: For comments where pushback is appropriate, the system MUST draft a professional rationale explaining why the suggestion was not incorporated, with alternatives where applicable.
- **FR-007**: System MUST generate an inline reply for each review comment thread, describing the action taken (code changed, suggestion declined with rationale, or follow-up planned).
- **FR-008**: System MUST post each inline reply to its respective comment thread after user confirmation. No top-level summary comment is posted.
- **FR-009**: System MUST allow the user to override any individual comment classification before action is taken.
- **FR-010**: System MUST push committed changes to the remote branch after user confirmation.
- **FR-011**: System MUST handle PRs with zero unresolved comments gracefully by reporting the status and exiting.
- **FR-012**: System MUST detect when the GitHub CLI is not available or not authenticated and provide actionable guidance.

### Key Entities

- **PR Comment**: A review comment on a pull request — has a body, author, file path (optional), line number (optional), and resolution status.
- **Comment Classification**: The category assigned to a comment — one of "required change", "suggestion", or "pushback".
- **Action Plan**: The set of all classified comments with their proposed actions, presented to the user for approval before execution.
- **Inline Reply**: A reply posted directly on a reviewer's comment thread, describing the action taken for that specific comment.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All unresolved PR comments are classified and addressed (via code change or rationale) in a single skill invocation.
- **SC-002**: The user can review and override all proposed actions before any commits or comments are made.
- **SC-003**: Each review comment thread receives a structured, professional inline reply covering the action taken.
- **SC-004**: No commit messages contain AI attribution or auto-generated labels.
- **SC-005**: The skill completes the full workflow (fetch, classify, act, summarize, post) within a single session without requiring the user to switch tools.
- **SC-006**: Comment classifications are consistent with what a Senior Member of Technical Staff would choose, as validated through manual review of classification results across test PRs.

## Clarifications

### Session 2026-03-30

- Q: Should the skill post individual inline replies to each comment thread, a top-level summary comment, or both? → A: Inline replies only — each comment thread gets a direct reply; no top-level summary comment is posted.
- Q: How should code changes from multiple comments be committed? → A: One commit per comment — each addressed comment gets its own dedicated commit for clean 1:1 traceability.
- Q: Which comment types are in scope — review comments (inline), top-level issue comments, or both? → A: Review comments only — inline code comments from formal reviews. Top-level issue comments are out of scope.

## Assumptions

- The user has the GitHub CLI (`gh`) installed and authenticated with appropriate permissions (read/write to the PR).
- The user is on the branch associated with the PR, or the PR number is provided as input.
- The repository is hosted on GitHub (not GitLab, Bitbucket, etc.).
- Comments from all reviewers are treated equally — no reviewer prioritization.
- "Unresolved" comments include all non-outdated review comments; resolved/outdated threads are skipped.
- The skill targets the PR associated with the current branch by default, but accepts an explicit PR number or URL as an argument.
