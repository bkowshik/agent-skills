# Research: Fix README Install Command

**Date**: 2026-03-09

## R1: Correct `npx skills add` syntax

**Decision**: Use `npx skills add bkowshik/git-skills` (owner/repo format, no trailing slash, no skill subdirectory)

**Rationale**: Verified from user's terminal testing:
- `npx skills add bkowshik/git-skills` — works, finds 1 skill, installs successfully
- `npx skills add bkowshik/git-skills/squash-commits` — fails with "No valid skills found"
- `npx skills add bkowshik/git-skills/` — fails with clone error due to trailing slash

**Alternatives considered**:
- `bkowshik/git-skills/squash-commits` — rejected, CLI doesn't support skill-specific paths
- `bkowshik/git-skills/` — rejected, trailing slash causes clone failure

## R2: README section placement

**Decision**: Add an "Installation" section between the repo description and the Skills table

**Rationale**: Follows standard README conventions — users expect install instructions near the top, before detailed feature listings. Placing it before the Skills table ensures users see how to install before browsing what's available.

**Alternatives considered**:
- Adding command inline within the Skills table — rejected, less discoverable
- Adding at the bottom — rejected, users may not scroll down
