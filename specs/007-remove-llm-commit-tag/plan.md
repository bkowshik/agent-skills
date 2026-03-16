# Implementation Plan: Remove LLM Attribution from Squashed Commit Messages

**Branch**: `007-remove-llm-commit-tag` | **Date**: 2026-03-16 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/007-remove-llm-commit-tag/spec.md`

## Summary

Remove LLM-generated Co-Authored-By attribution lines from squashed commit messages. Two changes: (1) update `squash.sh` to filter out known LLM/bot trailers from extracted trailers, and (2) update `SKILL.md` to explicitly instruct the agent not to add its own attribution to the synthesized commit message.

## Technical Context

**Language/Version**: Bash (existing helper script) + Markdown (SKILL.md authoring)
**Primary Dependencies**: Git 2.20+ (for trailer extraction via `%(trailers)` format)
**Storage**: N/A
**Testing**: Manual validation via eval scenarios (per constitution Principle IV: Eval-First)
**Target Platform**: Any platform with Bash and Git
**Project Type**: CLI skill (Markdown instructions + Bash helper script)
**Performance Goals**: N/A — no runtime performance concerns
**Constraints**: Must remain agent-agnostic per constitution Principle III
**Scale/Scope**: 2 files changed (squash.sh, SKILL.md)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Spec Compliance | Pass | Changes to SKILL.md preserve Agent Skills Specification format |
| II. Self-Contained | Pass | No new external dependencies introduced |
| III. Agent-Agnostic | Pass | Filtering uses email-pattern matching (not agent-specific logic); SKILL.md instructions describe *what* to do, not agent-specific commands |
| IV. Eval-First | Pass | Eval scenarios defined in spec acceptance scenarios |

No violations. Complexity Tracking table not needed.

## Project Structure

### Documentation (this feature)

```text
specs/007-remove-llm-commit-tag/
├── spec.md
├── plan.md              # This file
├── research.md          # Phase 0 output
└── data-model.md        # Phase 1 output
```

### Source Code (repository root)

```text
skills/squash-commits/
├── SKILL.md             # Modified: add no-attribution instruction in Step 2
└── scripts/
    └── squash.sh        # Modified: filter LLM trailers from extracted trailers
```

**Structure Decision**: No new files or directories needed. This feature modifies two existing files in the squash-commits skill.

## Design

### Change 1: Filter LLM trailers in `squash.sh` (FR-003)

In the trailer extraction section (line 180–181), add a filtering step after deduplication that removes trailers matching known LLM/bot email patterns.

**Filter patterns** (case-insensitive grep exclusion):
- `noreply@anthropic.com` — Claude / Anthropic tools
- `noreply@openai.com` — ChatGPT / OpenAI tools
- `noreply@google.com` — Gemini / Google AI tools
- `noreply@github.com` — GitHub Copilot
- `users.noreply.github.com` — GitHub bot accounts (e.g., `49699333+dependabot[bot]@users.noreply.github.com`)

Implementation: pipe the existing `TRAILERS` extraction through `grep -v -i -E` with a combined pattern. If all trailers are filtered out, `TRAILERS` becomes empty (same as no trailers).

**Why email-based matching**: Email patterns are stable identifiers that won't accidentally match human collaborators who happen to be named "Claude" or work at a company called "OpenAI". Name-based matching (filtering "Claude" from author names) would produce false positives.

### Change 2: Explicit no-attribution instruction in `SKILL.md` (FR-001, FR-004)

Add a clear instruction in Step 2 (Synthesize the commit message) telling the agent:
- Do NOT add your own name, attribution, or Co-Authored-By trailer to the commit message
- The commit message should contain only the synthesized summary and human-authored trailers from the original commits

This instruction goes in Step 2 because that's where the agent composes the final message. The agent-agnostic phrasing ("your own name") works for any LLM.

### Interaction between changes

Both changes work together as defense-in-depth:
- **squash.sh filtering** handles LLM trailers that already exist in the original commits (e.g., if previous commits were made with Claude Code's default behavior)
- **SKILL.md instruction** prevents the agent from adding new attribution when creating the squashed commit
