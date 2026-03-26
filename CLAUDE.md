# agent-skills Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-03-09

## Active Technologies
- Markdown + None (002-fix-readme-command)
- Markdown (SKILL.md authoring) + None — pure documentation change (003-fix-script-path)
- Markdown + JSON (no runtime language) + None (005-rename-repo)
- Markdown (SKILL.md authoring) + Bash (existing helper script, unchanged) + Git 2.20+ (for `--force-with-lease` support) (006-force-push-confirm)
- Bash (existing helper script) + Markdown (SKILL.md authoring) + Git 2.20+ (for trailer extraction via `%(trailers)` format) (007-remove-llm-commit-tag)
- Markdown (SKILL.md authoring) -- no runtime language + Existing speckit commands (`.claude/commands/speckit.*.md`), existing helper scripts (`.specify/scripts/bash/`) (008-speckit-auto)
- N/A -- artifacts written to `specs/` directory by existing speckit commands (008-speckit-auto)

- Markdown (SKILL.md) + Bash (helper script for git operations) + Git 2.20+ (001-squash-commits)

## Project Structure

```text
src/
tests/
```

## Commands

# Add commands for Markdown (SKILL.md) + Bash (helper script for git operations)

## Code Style

Markdown (SKILL.md) + Bash (helper script for git operations): Follow standard conventions

## Recent Changes
- 008-speckit-auto: Added Markdown (SKILL.md authoring) -- no runtime language + Existing speckit commands (`.claude/commands/speckit.*.md`), existing helper scripts (`.specify/scripts/bash/`)
- 007-remove-llm-commit-tag: Added Bash (existing helper script) + Markdown (SKILL.md authoring) + Git 2.20+ (for trailer extraction via `%(trailers)` format)
- 006-force-push-confirm: Added Markdown (SKILL.md authoring) + Bash (existing helper script, unchanged) + Git 2.20+ (for `--force-with-lease` support)


<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
