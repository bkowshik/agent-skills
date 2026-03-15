# Research: Rename Repository from git-skills to agent-skills

**Feature**: 005-rename-repo | **Date**: 2026-03-15

## Overview

This feature has no technical unknowns — it is a deterministic text replacement across a known set of files. Research is minimal and focused on confirming the exact scope.

## Decision 1: Replacement Scope

**Decision**: Replace "git-skills" → "agent-skills" only in user-facing files, not historical specs.

**Rationale**: Historical spec files (001–003) document decisions made when the repo was named "git-skills." Modifying them would misrepresent past decisions and break traceability.

**Alternatives considered**:
- Replace everywhere: Rejected — violates historical accuracy (FR-006 in spec).
- Replace nowhere in specs including 005: The 005 spec itself references "git-skills" as the subject of the rename — these references are intentional and should remain.

## Decision 2: Substring Safety

**Decision**: Replace the exact string "git-skills" (not a broader regex). No file in the repo contains "git-skills" as a substring of a longer token (e.g., "git-skills-extra" does not exist).

**Rationale**: Verified via grep — all 7 occurrences in user-facing files are either the standalone project name or part of the path `bkowshik/git-skills`. A direct string replacement is safe.

**Alternatives considered**:
- Word-boundary regex: Unnecessary given the grep results confirm no ambiguous substrings exist.

## Decision 3: GitHub Rename is Out of Scope

**Decision**: This feature only covers in-repo file content. The actual GitHub repository rename (Settings → Rename) is a separate manual step.

**Rationale**: Per the spec's assumptions section, the GitHub rename is the user's responsibility. GitHub automatically redirects the old URL, so in-repo references are the only thing that needs updating for consistency.

## File-Level Change Manifest

| File | Occurrences | Change |
|------|-------------|--------|
| README.md | 2 | `# git-skills` → `# agent-skills`; install command path |
| CLAUDE.md | 1 | `# git-skills Development Guidelines` → `# agent-skills Development Guidelines` |
| .specify/memory/constitution.md | 1 | `# git-skills Constitution` → `# agent-skills Constitution` |
| skills/squash-commits/README.md | 1 | Install command: `bkowshik/git-skills` → `bkowshik/agent-skills` |
| skills/learning-log/README.md | 1 | Install command: `bkowshik/git-skills` → `bkowshik/agent-skills` |
| skills-lock.json | 1 | `"source": "bkowshik/git-skills"` → `"source": "bkowshik/agent-skills"` |

**Total**: 7 replacements across 6 files.
