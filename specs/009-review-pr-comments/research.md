# Research: Review PR Comments

## R-001: Fetching PR Review Comments via GitHub CLI

**Decision**: Use the GitHub GraphQL API via `gh api graphql` to fetch review threads, since only GraphQL exposes `isResolved` and `isOutdated` status.

**Rationale**: The REST API (`/repos/{owner}/{repo}/pulls/{number}/comments`) returns inline review comments but lacks resolution/outdated status. The spec requires skipping resolved/outdated threads (FR-001, Assumptions), which is only possible through the GraphQL `reviewThreads` query.

**Alternatives considered**:
- REST API (`gh api repos/.../pulls/.../comments`): Simpler but lacks `isResolved`/`isOutdated` fields. Would require fetching all comments and guessing status.
- `gh pr view --json comments`: Only returns issue comments, not inline review comments. Not usable.

## R-002: Posting Inline Replies to Comment Threads

**Decision**: Use the REST API endpoint `POST /repos/{owner}/{repo}/pulls/{number}/comments/{comment_id}/replies` via `gh api` to post replies to individual review comment threads.

**Rationale**: This is the simplest and most reliable method. The `comment_id` is the ID of any comment in the thread (typically the root). The reply appears in the same conversation thread on the diff.

**Alternatives considered**:
- GraphQL mutation (`addPullRequestReviewComment`): More complex, requires creating a pending review first. Unnecessary for posting standalone replies.
- `gh pr comment`: Posts a top-level issue comment, not an inline reply. Not suitable.

## R-003: Key JSON Fields from GraphQL Review Threads

**Decision**: Use these fields from the GraphQL `reviewThreads` query:

| Field | Source | Purpose |
|-------|--------|---------|
| `isResolved` | `reviewThreads.nodes` | Filter out resolved threads |
| `isOutdated` | `reviewThreads.nodes` | Filter out outdated threads |
| `id` | `reviewThreads.nodes` | Thread identifier for resolution |
| `body` | `comments.nodes` | Comment text for classification |
| `author.login` | `comments.nodes` | Reviewer attribution |
| `path` | `comments.nodes` | File path for code changes |
| `line` | `comments.nodes` | Line number for code changes |
| `databaseId` | `comments.nodes` | REST API comment ID (needed for posting replies via REST) |

**Rationale**: GraphQL provides the complete picture in a single query — thread resolution status, all comments in a thread, and file/line context. The `databaseId` field bridges GraphQL and REST APIs (needed because reply posting uses the REST endpoint).

## R-004: Helper Script Design Pattern

**Decision**: Create a `fetch-comments.sh` helper script that handles all `gh` API interactions (fetching comments, posting replies, resolving threads). The SKILL.md instructs the agent on classification logic, action planning, and user interaction.

**Rationale**: Follows the established pattern from squash-commits — the helper script encapsulates tool-specific operations while the SKILL.md provides agent instructions. This keeps the skill agent-agnostic (constitution principle III) while isolating `gh` CLI specifics in a testable script.

**Alternatives considered**:
- No helper script (all `gh` commands inline in SKILL.md): Would make the SKILL.md overly long and couple it to specific API endpoints. Harder to maintain.
- Multiple helper scripts (one per operation): Unnecessary complexity for this scope.

## R-005: Pagination Strategy

**Decision**: Use `gh api graphql --paginate` for fetching review threads. GraphQL pagination uses cursors and `gh` handles this automatically when the query includes `$endCursor` parameter.

**Rationale**: PRs can have many review threads. The `--paginate` flag with GraphQL automatically follows cursors, ensuring all threads are fetched without manual pagination logic.

## R-006: Thread vs Comment Distinction

**Decision**: Operate at the **thread** level, not the individual comment level. Each review thread (which may contain multiple back-and-forth replies) is treated as one unit for classification. The root comment of the thread determines the classification.

**Rationale**: A thread represents a single piece of review feedback, even if it has follow-up discussion. Classifying at the thread level matches reviewer expectations — they left one piece of feedback and expect one response.
