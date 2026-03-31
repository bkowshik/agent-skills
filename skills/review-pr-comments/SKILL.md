---
name: review-pr-comments
description: >-
  Review all inline PR comments, classify each as a required change, suggestion,
  or pushback, then make code changes and post inline replies. Acts as a Senior
  Member of Technical Staff triaging review feedback. Trigger keywords: review PR
  comments, address PR feedback, handle review comments, triage PR comments,
  respond to PR review.
---

# Review PR Comments

Fetch all unresolved inline review comments from a GitHub PR, classify each as
"required change", "suggestion", or "pushback", make code changes for valid
items (one commit per comment), and post an inline reply to each comment thread
describing the action taken. No top-level summary comment is posted.

## How it works

The helper script at `{{SKILL_DIR}}/scripts/fetch-comments.sh` handles all
GitHub API interactions — fetching review threads via GraphQL and posting
inline replies via the REST API. You handle the classification, code changes,
commit message authoring, and user interaction.

The workflow moves through these states:

1. **Preflight** — the script verifies `gh` is installed and authenticated,
   detects the PR number, and checks push access
2. **Fetch** — the script fetches all active (unresolved, non-outdated) review
   threads and outputs structured JSON
3. **Classify** — you classify each thread as `required_change`, `suggestion`,
   or `pushback`
4. **Preview** — you present the classification and proposed actions to the
   user for approval (with override option)
5. **Execute** — you make code changes and create one commit per addressed
   comment (no AI attribution in commit messages)
6. **Reply** — you draft an inline reply for each thread and post it via the
   helper script after user confirmation
7. **Push** — you push committed changes to the remote branch after user
   confirmation

## Workflow

### Step 1: Fetch and display comments

Run the helper script in fetch mode:

```bash
{{SKILL_DIR}}/scripts/fetch-comments.sh --fetch
```

Or with an explicit PR number:

```bash
{{SKILL_DIR}}/scripts/fetch-comments.sh --fetch --pr <number>
```

The output is a JSON array of active review threads. Each thread has:
- `threadId` — GraphQL node ID
- `rootCommentId` — REST API database ID (used for posting replies)
- `path` — file path the comment is on
- `line` — line number in the diff (may be null for file-level comments)
- `author` — login of the reviewer
- `body` — text of the root comment (Markdown)
- `replyCount` — number of follow-up replies in the thread

If the script exits with an error, relay the error message to the user and
stop. Common errors: `gh` not installed, not authenticated, no open PR.

If the output is an empty array `[]`, report "No unresolved comments found"
and exit — there is nothing to process.

Display each thread in a numbered list for the user:

```
1. @reviewer — path/to/file.py:42
   "The error message here is misleading — it says 'not found' but the
   actual issue is a permissions check failure."

2. @reviewer2 — src/utils.ts:15
   "Consider using a Map instead of an object here for better performance."
```

### Step 2: Classify comments

For each thread, classify it into one of three categories based on the comment
content and the referenced code:

- **`required_change`** — The comment identifies a genuine bug, correctness
  issue, missing error handling, security concern, or a factual error. The code
  must be changed to address it.
- **`suggestion`** — The comment proposes a style improvement, refactor,
  naming change, or optional enhancement. The code may or may not change — use
  your judgment as a Senior Member of Technical Staff.
- **`pushback`** — The comment requests work that is out of scope, based on a
  misunderstanding, or proposes a change where the current approach is
  defensible. The suggestion should be declined with a rationale.

Present the classification as an informational table:

```
| # | Comment Summary           | Category         | Proposed Action              |
|---|---------------------------|------------------|------------------------------|
| 1 | Misleading error message  | required_change  | Update error message text    |
| 2 | Use Map for performance   | suggestion       | Apply — straightforward win  |
| 3 | Add retry logic           | pushback         | Out of scope for this PR     |
```

This is a read-only display. The user can review and override classifications
in the preview step (Step 3).

### Step 3: Present action plan and handle overrides

After classification, present a structured preview of all threads with their
classification, proposed action, and draft reply. Ask the user:

> "Here's the action plan. You can approve it, or override any classification
> before I proceed. Which items would you like to change?"

If the user changes a classification, update the proposed action and re-draft
the reply for that thread. Loop until the user approves the full plan.

Once approved, proceed to execute.

### Step 4: Execute code changes

For each comment classified as `required_change`:

1. Read the referenced file at the specified path and line
2. Understand the reviewer's concern in the context of the surrounding code
3. Apply the fix
4. Stage and commit the change with a concise, descriptive message

For each comment classified as `suggestion` that you decided to apply:

1. Apply the suggested change
2. Stage and commit with a descriptive message

**Commit message rules:**
- One commit per addressed comment — do NOT batch multiple fixes
- Use concise, descriptive messages that explain what was changed and why
- Do NOT include AI attribution, Co-Authored-By trailers, or any
  auto-generated labels in commit messages
- Match the voice and style of the project's existing commits

### Step 5: Draft pushback rationale

For each comment classified as `pushback`:

1. Draft a professional rationale explaining why the suggestion was not
   incorporated
2. Include specific reasoning — reference the current implementation's
   strengths, trade-offs considered, or scope boundaries
3. Where appropriate, suggest an alternative approach or offer to create a
   follow-up issue for future consideration
4. Keep the tone respectful and constructive — acknowledge the reviewer's
   perspective before explaining the decision

### Step 6: Draft and post inline replies

For each thread (regardless of classification), compose an inline reply
describing the action taken:

- **`required_change`**: "Fixed in [commit hash] — [brief description of what
  changed]."
- **`suggestion` (applied)**: "Good call — applied in [commit hash]."
- **`suggestion` (declined)**: "Considered this — [rationale for current
  approach]. Happy to discuss further."
- **`pushback`**: The rationale drafted in Step 5.

Present all draft replies to the user and ask for confirmation before posting.

After the user confirms, post each reply using the helper script:

```bash
{{SKILL_DIR}}/scripts/fetch-comments.sh --reply --pr <number> --comment-id <id> --body "<reply text>"
```

Report success or failure for each reply posted.

### Step 7: Push changes

After all commits are made and replies are posted, prompt the user:

> "All changes committed and replies posted. Push to remote?"

If the user confirms, run:

```bash
git push
```

Report success or failure. If the push fails (e.g., the remote has diverged),
show the error and suggest resolution steps.

## Edge cases

- **No unresolved comments**: The fetch returns an empty array. Report "No
  unresolved comments found" and exit gracefully.
- **Stale comment (references deleted/moved code)**: If a comment's path or
  line no longer exists in the current code, flag the comment as "stale" and
  ask the user how to proceed — they can skip it, manually locate the relevant
  code, or dismiss the thread.
- **gh CLI not installed**: The script detects this and exits with an error
  message including installation instructions. Relay the message to the user.
- **gh CLI not authenticated**: The script detects this and exits with an error
  asking the user to run `gh auth login`. Relay the message.
- **No push access**: The script detects this during preflight. Inform the user
  they need write access to the repository.
- **No open PR for current branch**: The script exits with an error. Ask the
  user to specify a PR number with `--pr <number>`.

## Specifying a PR

By default, the skill targets the PR associated with the current branch. The
helper script runs `gh pr view` to auto-detect the PR number.

If there is no open PR for the current branch, or you want to target a
different PR, pass it explicitly:

**By number:**

```bash
{{SKILL_DIR}}/scripts/fetch-comments.sh --fetch --pr 42
```

**By URL:**

```bash
{{SKILL_DIR}}/scripts/fetch-comments.sh --fetch --pr https://github.com/owner/repo/pull/42
```

The URL is parsed to extract the PR number. Both formats work for `--fetch`
and `--reply` modes.

Always confirm which PR is being targeted when the user invokes the skill.

## Example

A developer is on branch `feature/add-search` with PR #42 open. The PR has
3 unresolved review comments.

### 1. Fetch comments

```bash
{{SKILL_DIR}}/scripts/fetch-comments.sh --fetch --pr 42
```

Output:

```json
[
  {
    "threadId": "PRRT_kwDO..._1",
    "rootCommentId": 1001,
    "path": "src/search.py",
    "line": 45,
    "author": "alice",
    "body": "This catches `Exception` which is too broad — it will swallow connection errors. Catch `ValueError` instead.",
    "replyCount": 0
  },
  {
    "threadId": "PRRT_kwDO..._2",
    "rootCommentId": 1002,
    "path": "src/search.py",
    "line": 12,
    "author": "bob",
    "body": "Nit: consider renaming `q` to `query_string` for readability.",
    "replyCount": 0
  },
  {
    "threadId": "PRRT_kwDO..._3",
    "rootCommentId": 1003,
    "path": "src/search.py",
    "line": 78,
    "author": "alice",
    "body": "Can you add retry logic with exponential backoff for the API call here?",
    "replyCount": 1
  }
]
```

### 2. Display and classify

```
1. @alice — src/search.py:45
   "This catches Exception which is too broad — it will swallow connection
   errors. Catch ValueError instead."

2. @bob — src/search.py:12
   "Nit: consider renaming q to query_string for readability."

3. @alice — src/search.py:78
   "Can you add retry logic with exponential backoff for the API call here?"
```

Classification:

```
| # | Comment Summary              | Category        | Proposed Action                     |
|---|------------------------------|-----------------|-------------------------------------|
| 1 | Too-broad exception catch    | required_change | Narrow catch to ValueError          |
| 2 | Rename q to query_string     | suggestion      | Apply — improves readability        |
| 3 | Add retry with backoff       | pushback        | Out of scope — suggest follow-up    |
```

### 3. User approves the plan

### 4. Execute changes

Commit 1: `Narrow exception catch from Exception to ValueError in search`
Commit 2: `Rename q parameter to query_string for readability`

### 5. Draft and post replies

```bash
{{SKILL_DIR}}/scripts/fetch-comments.sh --reply --pr 42 --comment-id 1001 --body "Fixed in abc1234 — narrowed the catch clause to ValueError so connection errors propagate correctly."

{{SKILL_DIR}}/scripts/fetch-comments.sh --reply --pr 42 --comment-id 1002 --body "Good call — applied in def5678. Renamed to query_string throughout."

{{SKILL_DIR}}/scripts/fetch-comments.sh --reply --pr 42 --comment-id 1003 --body "I'd prefer to keep this PR focused on the core search functionality. Retry logic with backoff is a good idea but would add complexity and testing scope beyond what this PR covers. Happy to open a follow-up issue for it — would that work?"
```

### 6. Push changes

```bash
git push
```

Done — 2 code changes committed, 3 inline replies posted, changes pushed.
