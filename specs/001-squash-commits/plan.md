# Implementation Plan: Squash Commits

**Branch**: `001-squash-commits` | **Date**: 2026-03-09 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-squash-commits/spec.md`

## Summary

A git skill that squashes all commits on a feature branch into a single commit with a coherent, synthesized commit message. The skill is a `SKILL.md` markdown file conforming to the Agent Skills Specification — no compiled code, no runtime dependencies beyond git. The agent reads the instructions and executes git commands to perform the squash.

## Technical Context

**Language/Version**: Markdown (SKILL.md) + Bash (helper script for git operations)
**Primary Dependencies**: Git 2.20+
**Storage**: N/A (operates on git repository state)
**Testing**: Manual eval scenarios — run the skill with different AI coding tools and verify git state
**Target Platform**: macOS and Linux (any platform with git)
**Project Type**: Agent skill (SKILL.md per Agent Skills Specification)
**Performance Goals**: Under 5 seconds for branches with up to 50 commits
**Constraints**: SKILL.md body under 5000 tokens (~500 lines); self-contained directory
**Scale/Scope**: Single skill, single directory

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Spec Compliance | Pass | SKILL.md with required frontmatter (`name`, `description`), directory matches name |
| II. Self-Contained | Pass | Single directory with SKILL.md and optional scripts/ — no cross-skill references |
| III. Agent-Agnostic | Pass | Instructions describe what to do and why, no tool-specific names or APIs |
| IV. Eval-First | Pass | Spec defines acceptance scenarios for happy path and errors; plan includes eval scenarios |

No violations. Gate passed.

## Project Structure

### Documentation (this feature)

```text
specs/001-squash-commits/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
skills/
└── squash-commits/
    ├── SKILL.md          # The skill instructions
    └── scripts/
        └── squash.sh     # Helper script for git operations
```

**Structure Decision**: Single skill directory under `skills/` following the Agent Skills Specification layout. A helper bash script handles the git operations (backup, reset) so the SKILL.md body stays focused on instructions. The agent handles the final commit with the synthesized message.

## Complexity Tracking

No constitution violations to justify.
