# Quickstart: Speckit Auto

**Feature**: 008-speckit-auto | **Date**: 2026-03-26

## Usage

```
/speckit-auto Add user authentication with OAuth2
```

The command takes a feature description as its argument and runs the full speckit pipeline without interruption.

## What happens

1. **Precondition check** -- verifies clean working directory, no existing branch for this feature
2. **Specify** -- creates feature branch, generates `spec.md` from the description
3. **Clarify** -- scans spec for ambiguities, auto-resolves them using best practices
4. **Plan** -- generates `plan.md`, `research.md`, `data-model.md`, `quickstart.md`
5. **Tasks** -- generates `tasks.md` with dependency-ordered implementation tasks
6. **Analyze** -- validates consistency across spec, plan, and tasks; auto-fixes any issues
7. **Implement** -- executes the implementation plan

## Expected output

Progress messages at each step transition:

```
## Step 1/6: Specify
Starting specification generation...
✓ Specify complete. Created specs/009-user-auth/spec.md

## Step 2/6: Clarify
Starting ambiguity scan...
Auto-resolved 2 clarifications (documented in Assumptions)
✓ Clarify complete. Updated specs/009-user-auth/spec.md

## Step 3/6: Plan
Starting implementation planning...
✓ Plan complete. Created plan.md, research.md, data-model.md, quickstart.md

## Step 4/6: Tasks
Starting task generation...
✓ Tasks complete. Created specs/009-user-auth/tasks.md

## Step 5/6: Analyze
Starting cross-artifact consistency check...
✓ Analyze complete. No inconsistencies found.

## Step 6/6: Implement
Starting implementation...
✓ Implement complete.

## Pipeline Complete
Branch: 009-user-auth
Artifacts: spec.md, plan.md, research.md, data-model.md, quickstart.md, tasks.md
Implementation: [list of created/modified source files]
No git commits were made. Review changes with `git status` and `git diff`.
```

## Failure scenario

If a step fails, the pipeline halts and reports:

```
## Step 5/6: Analyze
Starting cross-artifact consistency check...
✗ Analyze found 2 inconsistencies. Attempting auto-fix...
✗ Auto-fix failed. 1 inconsistency remains.

Pipeline halted at: Analyze (step 5/6)
Error: Unresolved inconsistency between plan.md and tasks.md
Artifacts preserved: spec.md, plan.md, research.md, data-model.md, quickstart.md, tasks.md
Resume with: /speckit.analyze
```

## Testing scenarios

### Happy path
Run `/speckit-auto "Add a simple greeting endpoint"` on a clean repo. Verify all 6 steps complete and all artifacts exist.

### Failure recovery
Run on a repo with uncommitted changes. Verify the pipeline refuses to start with a clear error message.

### Auto-clarify
Run with a vague description (e.g., `/speckit-auto "Make it better"`). Verify the specify step either refuses (too vague) or the clarify step auto-resolves ambiguities and documents assumptions.
