# Implementation Plan: Rename Repository from git-skills to agent-skills

**Branch**: `005-rename-repo` | **Date**: 2026-03-15 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/005-rename-repo/spec.md`

## Summary

Rename all user-facing references from "git-skills" to "agent-skills" across 6 files (README.md, CLAUDE.md, constitution, skill READMEs, skills-lock.json) while preserving historical spec files (001–003) untouched. This is a pure text-replacement task with no code, dependencies, or build steps.

## Technical Context

**Language/Version**: Markdown + JSON (no runtime language)
**Primary Dependencies**: None
**Storage**: N/A
**Testing**: Manual grep verification (`grep -r "git-skills"` post-rename)
**Target Platform**: N/A (documentation-only change)
**Project Type**: Skill repository (markdown-based)
**Performance Goals**: N/A
**Constraints**: Must not modify files in specs/001-*, specs/002-*, specs/003-*
**Scale/Scope**: 6 files, ~7 string replacements total

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Spec Compliance | PASS | Renaming the repo does not alter SKILL.md format or content — skills remain spec-compliant |
| II. Self-Contained | PASS | Each skill directory is unchanged structurally; only README install commands update the repo path |
| III. Agent-Agnostic | PASS | No agent-specific instructions are introduced |
| IV. Eval-First | PASS | Verification is a simple grep for zero "git-skills" matches in user-facing files |

**Gate result**: All clear — no violations.

## Project Structure

### Documentation (this feature)

```text
specs/005-rename-repo/
├── spec.md              # Feature specification
├── plan.md              # This file
├── research.md          # Phase 0 output (minimal — no unknowns)
├── data-model.md        # Phase 1 output (file-change manifest)
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
# Files to MODIFY (user-facing)
README.md                          # heading + install command
CLAUDE.md                          # heading
.specify/memory/constitution.md    # heading
skills/squash-commits/README.md    # install command
skills/learning-log/README.md      # install command
skills-lock.json                   # source field

# Files to PRESERVE (historical specs — DO NOT TOUCH)
specs/001-squash-commits/          # all files untouched
specs/002-fix-readme-command/      # all files untouched
specs/003-fix-script-path/         # all files untouched
```

**Structure Decision**: No structural changes. This is a find-and-replace across existing files only.

## Complexity Tracking

No constitution violations — table not needed.
