# Implementation Plan: Force Push with Confirmation

**Branch**: `006-force-push-confirm` | **Date**: 2026-03-15 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/006-force-push-confirm/spec.md`

## Summary

Modify the squash-commits skill's SKILL.md to replace the passive "remind them to run `git push --force-with-lease`" instruction in Step 6 with an active confirmation-and-execute flow. When `HAS_UPSTREAM=true`, the agent warns about diverged history, asks the user to confirm, executes the force push on confirmation, handles failures gracefully, and falls back to showing the manual command on decline or error.

## Technical Context

**Language/Version**: Markdown (SKILL.md authoring) + Bash (existing helper script, unchanged)
**Primary Dependencies**: Git 2.20+ (for `--force-with-lease` support)
**Storage**: N/A
**Testing**: Eval-first — validate through expected agent behavior across scenarios (per constitution principle IV)
**Target Platform**: Any platform with git CLI
**Project Type**: Agent skill (markdown instructions consumed by AI coding tools)
**Performance Goals**: N/A
**Constraints**: Change is limited to SKILL.md only; the helper script `squash.sh` is not modified
**Scale/Scope**: Single file change (~20 lines modified/added in Step 6)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Spec Compliance | PASS | SKILL.md format unchanged; only workflow instructions updated |
| II. Self-Contained | PASS | No new external dependencies; uses git which is already required |
| III. Agent-Agnostic | PASS | Instructions describe *what* to do (ask user, run command, show output) without naming specific AI tools |
| IV. Eval-First | PASS | Acceptance scenarios in spec are behavioral; tested by running the skill |

No violations. No complexity tracking needed.

## Project Structure

### Documentation (this feature)

```text
specs/006-force-push-confirm/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
└── quickstart.md        # Phase 1 output
```

### Source Code (repository root)

```text
skills/squash-commits/
├── SKILL.md             # Modified: Step 6 updated with force-push confirmation flow
├── README.md            # Unchanged
└── scripts/
    └── squash.sh        # Unchanged
```

**Structure Decision**: No new files or directories. The change is a targeted edit to Step 6 (and minor adjustments to Step 4) of the existing `skills/squash-commits/SKILL.md`.
