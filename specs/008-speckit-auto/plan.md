# Implementation Plan: Speckit Auto

**Branch**: `008-speckit-auto` | **Date**: 2026-03-26 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/008-speckit-auto/spec.md`

## Summary

Create a new skill (`skills/speckit-auto/`) that orchestrates the full speckit pipeline -- specify, clarify, plan, tasks, analyze, implement -- in a single uninterrupted command. The skill is a SKILL.md file that instructs the LLM to invoke each speckit step sequentially, auto-resolving decisions at each step, with progress reporting and graceful failure handling. No helper scripts are needed; all orchestration logic lives in the SKILL.md instructions.

## Technical Context

**Language/Version**: Markdown (SKILL.md authoring) -- no runtime language
**Primary Dependencies**: Existing speckit commands (`.claude/commands/speckit.*.md`), existing helper scripts (`.specify/scripts/bash/`)
**Storage**: N/A -- artifacts written to `specs/` directory by existing speckit commands
**Testing**: Eval-first (per constitution) -- validate through behavioral scenarios across AI coding tools
**Target Platform**: Any environment running Claude Code with the speckit commands installed
**Project Type**: Skill (Agent Skills Specification v1.0)
**Performance Goals**: N/A -- execution time is determined by the underlying speckit steps
**Constraints**: No git commits during execution; all artifacts remain uncommitted
**Scale/Scope**: Single skill file (~200-300 lines), no helper scripts needed

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Spec Compliance | PASS | Skill follows Agent Skills Specification format (YAML frontmatter + Markdown body) |
| II. Self-Contained | PASS | Skill directory contains only SKILL.md and README.md. References to speckit commands use `{{SKILL_DIR}}` or are external commands the host project provides. The skill itself is independently installable. |
| III. Agent-Agnostic | PASS | SKILL.md describes *what* to do and *why*, not specific tool APIs. Any LLM-based coding tool can follow the instructions. |
| IV. Eval-First | PASS | Success validated through behavioral scenarios (pipeline runs end-to-end, progress reported, failures handled). No unit tests needed for Markdown. |

No violations. Complexity Tracking section not needed.

**Post-Phase 1 re-check**: All principles still pass. The design adds one SKILL.md file and one README.md -- no new runtime dependencies, no cross-skill references, no tool-specific APIs.

## Project Structure

### Documentation (this feature)

```text
specs/008-speckit-auto/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (via /speckit.tasks)
```

### Source Code (repository root)

```text
skills/
└── speckit-auto/
    ├── SKILL.md          # Skill definition -- all orchestration logic
    └── README.md         # User-facing documentation
```

**Structure Decision**: Follows the established skill pattern (see `skills/learning-log/` which also has no helper scripts). No `scripts/` directory needed because the orchestration is purely instructional -- the SKILL.md tells the LLM which speckit commands to invoke and how to handle each step's output. The deterministic work (branch creation, prereq checks) is already handled by existing `.specify/scripts/bash/` scripts that the speckit commands call internally.
