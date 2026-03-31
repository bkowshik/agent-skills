# Implementation Plan: Review PR Comments

**Branch**: `009-review-pr-comments` | **Date**: 2026-03-30 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/009-review-pr-comments/spec.md`

## Summary

A Claude Code skill that fetches inline review comments from a GitHub PR, classifies each as "required change", "suggestion", or "pushback", makes code changes (one commit per comment), drafts inline replies, and posts them to each comment thread — all with user confirmation at each step. Follows the same SKILL.md + helper script pattern used by the existing squash-commits skill.

## Technical Context

**Language/Version**: Bash 4+ (helper script), Markdown (SKILL.md authoring)
**Primary Dependencies**: GitHub CLI (`gh`) for PR comment fetching and reply posting, Git 2.20+ for commit operations
**Storage**: N/A
**Testing**: Manual eval-based testing per constitution (Eval-First principle) — validate behavior across AI coding tools
**Target Platform**: Any platform with Bash, Git, and `gh` CLI
**Project Type**: Agent skill (Markdown SKILL.md + Bash helper script)
**Performance Goals**: N/A — interactive skill, human-in-the-loop
**Constraints**: Must work with any GitHub-hosted repository; must not require any dependencies beyond `gh` and `git`
**Scale/Scope**: Single PR at a time; handles up to ~50 review comments per invocation (GitHub API practical limit)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Spec Compliance | PASS | Skill will follow Agent Skills Specification v1.0 — YAML frontmatter with `name` and `description`, structured Markdown body |
| II. Self-Contained | PASS | Skill directory contains SKILL.md, README.md, and scripts/ — no external references beyond system tools (`gh`, `git`) |
| III. Agent-Agnostic | PASS | SKILL.md describes *what* to do and *why*, not specific tool APIs. Works with any LLM-based coding agent |
| IV. Eval-First | PASS | Validation through behavioral scenarios (PR with mixed comment types), not unit tests |

No violations. Gate passed.

## Project Structure

### Documentation (this feature)

```text
specs/009-review-pr-comments/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
skills/
└── review-pr-comments/
    ├── SKILL.md          # Skill definition (agent instructions)
    ├── README.md         # User-facing documentation
    └── scripts/
        └── fetch-comments.sh  # Helper: fetch & format PR review comments via gh CLI
```

**Structure Decision**: Follows the established pattern from squash-commits — a SKILL.md for agent instructions, a README.md for user docs, and a scripts/ directory for Bash helpers that handle tool-specific operations (in this case, `gh` API calls for fetching comments and posting replies).
