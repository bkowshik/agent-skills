# Implementation Plan: Fix Script Path Resolution

**Branch**: `003-fix-script-path` | **Date**: 2026-03-10 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/003-fix-script-path/spec.md`

## Summary

Replace all 9 hardcoded `scripts/squash.sh` references in the squash-commits SKILL.md with `{{SKILL_DIR}}/scripts/squash.sh` placeholders. This makes path resolution LLM-agnostic — each tool's skill loader resolves `{{SKILL_DIR}}` to the actual filesystem path at read time.

## Technical Context

**Language/Version**: Markdown (SKILL.md authoring)
**Primary Dependencies**: None — pure documentation change
**Storage**: N/A
**Testing**: Manual validation — invoke `/squash-commits` and verify script found on first attempt
**Target Platform**: Any LLM coding tool (Claude Code, Cursor, Copilot, etc.)
**Project Type**: Agent skill (Markdown-based instruction set with helper scripts)
**Performance Goals**: N/A
**Constraints**: Must comply with Agent Skills Specification; skill must remain self-contained
**Scale/Scope**: Single file change (SKILL.md), 9 path references to update

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Spec Compliance | PASS | SKILL.md follows agent skills specification format; `{{SKILL_DIR}}` is a portable convention |
| II. Self-Contained | PASS | `{{SKILL_DIR}}/scripts/squash.sh` references a file within the skill's own directory — self-contained |
| III. Agent-Agnostic | PASS | `{{SKILL_DIR}}` placeholder is LLM-agnostic by design; each tool resolves it independently |
| IV. Eval-First | PASS | Validation is behavioral — invoke the skill and confirm the script is found on first attempt |

All gates pass. No violations to justify.

## Project Structure

### Documentation (this feature)

```text
specs/003-fix-script-path/
├── spec.md
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output (N/A for this feature)
├── quickstart.md        # Phase 1 output
└── checklists/
    └── requirements.md
```

### Source Code (repository root)

```text
.agents/skills/squash-commits/
├── SKILL.md             # File to modify — replace all scripts/squash.sh paths
├── README.md
└── scripts/
    └── squash.sh        # Helper script — NOT modified
```

**Structure Decision**: No new files or directories needed. Single file edit to `.agents/skills/squash-commits/SKILL.md`.
