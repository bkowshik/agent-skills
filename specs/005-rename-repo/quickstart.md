# Quickstart: Rename Repository from git-skills to agent-skills

**Feature**: 005-rename-repo | **Date**: 2026-03-15

## What This Feature Does

Replaces all user-facing references from "git-skills" to "agent-skills" across the repository, while preserving historical spec files unchanged.

## How to Verify

After implementation, run:

```bash
# Should return ZERO results (no user-facing files with old name)
grep -r "git-skills" --include="*.md" --include="*.json" . | grep -v "specs/00[1-3]" | grep -v "specs/005"

# Should return results (historical specs preserved)
grep -r "git-skills" specs/001-squash-commits/ specs/002-fix-readme-command/ specs/003-fix-script-path/
```

## Files Changed

| File | What Changed |
|------|-------------|
| `README.md` | Heading + install command |
| `CLAUDE.md` | Heading |
| `.specify/memory/constitution.md` | Heading |
| `skills/squash-commits/README.md` | Install command |
| `skills/learning-log/README.md` | Install command |
| `skills-lock.json` | Source field |

## Post-Implementation

After merging this PR, manually rename the GitHub repository:
**Settings → General → Repository name → `agent-skills`**

GitHub will automatically redirect the old URL.
