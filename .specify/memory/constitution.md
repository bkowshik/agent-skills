# agent-skills Constitution

## Core Principles

### I. Spec Compliance

The [Agent Skills Specification](https://agentskills.io/specification.md) is the authoritative format standard. Compliance is what makes skills portable across the ecosystem — without it, a skill that works in one tool breaks in another.

### II. Self-Contained

Each skill is independently installable. If a skill references anything outside its own directory, distribution breaks. Each skill has a single responsibility; compose multi-step workflows from separate skills.

### III. Agent-Agnostic

Skills are consumed by many AI coding tools, so instructions need to work for any LLM. Describe *what* to do and *why*, rather than naming specific tools or APIs. Explain reasoning behind constraints so the agent can handle edge cases the rules don't explicitly cover.

### IV. Eval-First

Skills are markdown — correctness is validated through expected behavior, not unit tests. Define scenarios covering the happy path and common errors, and validate across multiple AI coding tools to confirm consistent behavior.

## Governance

This constitution is the authoritative source of project principles. Evaluate all design decisions, code reviews, and PRs against these principles.

- **Amendments**: Document changes with a version bump, rationale, and updated date.
- **Versioning**: Major for principle removals or redefinitions, minor for new principles or expanded guidance, patch for clarifications and wording fixes.
- **Compliance**: Include a constitution compliance check in each PR review. Justify any violations in the PR description.

**Version**: 6.0.0 | **Ratified**: 2026-03-09 | **Last Amended**: 2026-03-09
