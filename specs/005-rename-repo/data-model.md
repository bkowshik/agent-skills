# Data Model: Rename Repository from git-skills to agent-skills

**Feature**: 005-rename-repo | **Date**: 2026-03-15

## Overview

This feature has no traditional data model — there are no entities, databases, or state transitions. The "model" is the set of files and the string replacements applied to them.

## File Change Model

### Entity: Renameable File

A file in the repository that contains user-facing references to the old project name.

| Field | Type | Description |
|-------|------|-------------|
| path | string | Absolute path to the file |
| format | enum(md, json) | File format determining replacement approach |
| occurrences | int | Number of "git-skills" matches to replace |
| old_value | string | The exact string being replaced |
| new_value | string | The replacement string |

### Instances

| Path | Format | Occurrences | Old → New |
|------|--------|-------------|-----------|
| README.md | md | 2 | `git-skills` → `agent-skills` |
| CLAUDE.md | md | 1 | `git-skills` → `agent-skills` |
| .specify/memory/constitution.md | md | 1 | `git-skills` → `agent-skills` |
| skills/squash-commits/README.md | md | 1 | `git-skills` → `agent-skills` |
| skills/learning-log/README.md | md | 1 | `git-skills` → `agent-skills` |
| skills-lock.json | json | 1 | `git-skills` → `agent-skills` |

### Entity: Protected File

A file that MUST NOT be modified, even though it contains "git-skills" references.

| Path | Reason |
|------|--------|
| specs/001-squash-commits/* | Historical spec (FR-006) |
| specs/002-fix-readme-command/* | Historical spec (FR-006) |
| specs/003-fix-script-path/* | Historical spec (FR-006) |
| specs/005-rename-repo/spec.md | Rename spec itself — references are intentional |

## Validation Rules

1. After replacement: `grep -r "git-skills" --include="*.md" --include="*.json" . | grep -v specs/` must return zero results.
2. After replacement: files in `specs/001-*`, `specs/002-*`, `specs/003-*` must have identical git diff (no changes).
