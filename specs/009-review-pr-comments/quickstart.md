# Quickstart: Review PR Comments

## Prerequisites

- GitHub CLI (`gh`) installed and authenticated: `gh auth status`
- Git 2.20+
- On a branch with an open PR (or know the PR number)

## Installation

Copy the `skills/review-pr-comments/` directory into your project's skills directory (or add this repository as a skill source in your AI coding tool).

## Usage

From a branch with an open PR:

```
/review-pr-comments
```

Or specify a PR number:

```
/review-pr-comments 42
```

Or a PR URL:

```
/review-pr-comments https://github.com/owner/repo/pull/42
```

## What Happens

1. **Fetch**: The skill fetches all unresolved inline review comments from the PR
2. **Classify**: Each comment thread is classified as "required change", "suggestion", or "pushback"
3. **Preview**: You see the full action plan and can override any classification
4. **Execute**: Code changes are made (one commit per comment), pushback rationale is drafted
5. **Reply**: Inline replies are posted to each comment thread after your confirmation
6. **Push**: Committed changes are pushed to the remote branch

## Key Behaviors

- **No AI attribution** in commit messages or replies
- **One commit per comment** for clean traceability
- **Inline replies only** — no top-level summary comment
- **User confirmation required** before commits and replies
- Resolved and outdated threads are automatically skipped
