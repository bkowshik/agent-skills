# Implementation Plan: Fix README Install Command

**Branch**: `002-fix-readme-command` | **Date**: 2026-03-09 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/002-fix-readme-command/spec.md`

## Summary

Add a working install command to the README so users can install skills with a single copy-paste. The current README has no install instructions. The correct command is `npx skills add bkowshik/git-skills` — variants with trailing slashes or skill subdirectory paths fail.

## Technical Context

**Language/Version**: Markdown
**Primary Dependencies**: None
**Storage**: N/A
**Testing**: Manual — copy command from README and run it
**Target Platform**: GitHub README (rendered markdown)
**Project Type**: Documentation fix for a skills repository
**Performance Goals**: N/A
**Constraints**: Must use `owner/repo` format per `npx skills` CLI requirements
**Scale/Scope**: Single file change (README.md)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Spec Compliance | PASS | README change doesn't affect SKILL.md format compliance |
| II. Self-Contained | PASS | No changes to skill directories; README is repo-level documentation |
| III. Agent-Agnostic | PASS | Install command works across all AI coding tools |
| IV. Eval-First | PASS | Testable by running the command and verifying installation succeeds |

**Gate result**: PASS — no violations.

## Project Structure

### Documentation (this feature)

```text
specs/002-fix-readme-command/
├── plan.md              # This file
├── research.md          # Phase 0 output
└── quickstart.md        # Phase 1 output
```

### Source Code (repository root)

```text
README.md                # Only file modified — add Installation section
```

**Structure Decision**: No new directories or source files needed. This is a single-file documentation edit to README.md at the repository root.

## Complexity Tracking

> No constitution violations — this section is not applicable.
