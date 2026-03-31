# review-pr-comments

Review all inline PR comments, classify each as a required change, suggestion, or pushback, then make code changes and post inline replies. Acts as a Senior Member of Technical Staff triaging review feedback.

## Install

```bash
npx skills add bkowshik/agent-skills
```

## Usage

From a branch with an open PR, ask your AI coding tool:

> Review the PR comments on this branch.

Or specify a PR number:

> Review the comments on PR #42.

The agent will:
1. Fetch all unresolved inline review comments
2. Classify each as "required change", "suggestion", or "pushback"
3. Show the action plan and let you override any classification
4. Make code changes (one commit per comment) and draft pushback rationale
5. Post an inline reply to each comment thread
6. Push changes to the remote branch

## Requirements

- GitHub CLI (`gh`) installed and authenticated: `gh auth status`
- Git 2.20+
- Push access to the PR's branch

## Key Behaviors

- **No AI attribution** in commit messages or replies
- **One commit per comment** for clean traceability
- **Inline replies only** — no top-level summary comment
- **User confirmation required** before commits, replies, and push
- Resolved and outdated threads are automatically skipped
