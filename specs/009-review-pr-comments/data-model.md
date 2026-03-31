# Data Model: Review PR Comments

## Entities

### ReviewThread

Represents a single review feedback thread on a PR. This is the primary unit of work.

| Attribute | Type | Description |
|-----------|------|-------------|
| threadId | string | GraphQL node ID (e.g., `PRRT_kwDO...`) |
| rootCommentId | integer | REST API database ID of the root comment (used for posting replies) |
| isResolved | boolean | Whether the thread has been marked resolved |
| isOutdated | boolean | Whether the referenced code has changed since the comment |
| path | string | File path the comment is on |
| line | integer or null | Line number in the current diff |
| author | string | Login of the reviewer who started the thread |
| body | string | Text of the root comment (Markdown) |
| replies | list of Comment | Follow-up comments in the thread |

**Identity**: Uniquely identified by `threadId`.
**Lifecycle**: Fetched → Classified → Acted on → Reply posted.
**Validation**: Threads where `isResolved = true` or `isOutdated = true` are filtered out before classification.

### CommentClassification

The triage result for a single review thread.

| Attribute | Type | Description |
|-----------|------|-------------|
| threadId | string | Reference to the ReviewThread |
| category | enum | One of: `required_change`, `suggestion`, `pushback` |
| rationale | string | Brief explanation of why this classification was chosen |
| proposedAction | string | Description of what will be done (code change summary, pushback text, etc.) |
| userOverride | enum or null | If user overrides, the new category; null if accepted as-is |

**Identity**: One-to-one with ReviewThread (keyed by `threadId`).
**Lifecycle**: Created during classification → May be overridden by user → Consumed during action execution.

### ActionPlan

The aggregate set of all classified threads, presented to the user for approval.

| Attribute | Type | Description |
|-----------|------|-------------|
| prNumber | integer | Pull request number |
| prUrl | string | Pull request URL |
| totalThreads | integer | Count of threads fetched (before filtering) |
| activeThreads | integer | Count after filtering resolved/outdated |
| classifications | list of CommentClassification | All classifications for active threads |

**Lifecycle**: Built after classification → Presented to user → User approves/modifies → Consumed during execution.

### InlineReply

A reply to be posted on a review comment thread.

| Attribute | Type | Description |
|-----------|------|-------------|
| rootCommentId | integer | REST API comment ID to reply to |
| body | string | Reply text (Markdown) — describes action taken |
| posted | boolean | Whether the reply has been successfully posted |

**Identity**: One-to-one with CommentClassification.
**Lifecycle**: Drafted after action → Confirmed by user → Posted via REST API.

## Relationships

```
ActionPlan 1───* CommentClassification 1───1 ReviewThread
                                        1───1 InlineReply
```

## State Transitions

### ReviewThread Lifecycle
```
Fetched → [filter: skip resolved/outdated] → Active → Classified → Action Taken → Reply Posted
```

### Skill Workflow States
```
Preflight Check → Fetch Threads → Classify → Present Plan → [User Confirms] → Execute Changes → Draft Replies → [User Confirms] → Post Replies → Done
```
