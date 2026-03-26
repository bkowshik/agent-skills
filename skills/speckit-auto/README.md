# speckit-auto

Run the full speckit pipeline (specify, clarify, plan, tasks, analyze, implement) end-to-end from a single command. Auto-resolves all decisions at each step without user interruption.

## Usage

```
/speckit-auto <feature description>
```

**Examples:**

```
/speckit-auto Add user authentication with OAuth2
/speckit-auto Create a dashboard for analytics
/speckit-auto Fix payment processing timeout bug
```

## What it does

1. **Specify** -- creates feature branch and spec.md from your description
2. **Clarify** -- scans for ambiguities and auto-resolves them
3. **Plan** -- generates implementation plan and design documents
4. **Tasks** -- creates dependency-ordered task breakdown
5. **Analyze** -- validates cross-artifact consistency, auto-fixes issues
6. **Implement** -- executes the implementation plan

No git commits are made. All artifacts and code remain uncommitted for your review.

## Requirements

- The speckit command suite must be installed (`.claude/commands/speckit.*.md`)
- A valid `.specify/` directory with templates, scripts, and project constitution
- Clean git working directory (no uncommitted changes)

## Recovery

If the pipeline fails at any step, it reports:
- Which step failed and why
- All artifacts preserved from completed steps
- The exact command to resume from the failed step
