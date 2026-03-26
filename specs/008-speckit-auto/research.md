# Research: Speckit Auto

**Feature**: 008-speckit-auto | **Date**: 2026-03-26

## R1: How do existing speckit commands handle inter-step communication?

**Decision**: Each speckit command independently discovers the current feature context by running `.specify/scripts/bash/check-prerequisites.sh --json --paths-only`, which returns the feature directory, spec file, plan file, and tasks file paths based on the current git branch name. No explicit state is passed between commands.

**Rationale**: This means the auto skill doesn't need to manage state passing. Each step reads from disk (artifacts written by previous steps) and discovers paths via the prerequisite script. The orchestrator just needs to ensure it's on the right branch and invoke each command in order.

**Alternatives considered**:
- Passing paths explicitly between steps: Unnecessary -- the prereq script already handles discovery.
- Maintaining a pipeline state file: Overengineering -- the existing file-based artifact discovery is sufficient.

## R2: How should the auto skill invoke speckit commands?

**Decision**: The SKILL.md instructs the LLM to invoke each speckit command using the `/speckit.*` skill invocation syntax (e.g., `/speckit.specify <description>`). The LLM calls each skill sequentially within the same conversation session.

**Rationale**: This is how all speckit commands are designed to be used. The skill-invocation approach means:
- Each command's full prompt/workflow is loaded and executed by the LLM
- The LLM retains conversation context across steps (can reference earlier outputs)
- No subprocess spawning or session management needed

**Alternatives considered**:
- Bash script spawning separate Claude sessions: Complex, loses conversation context, requires session orchestration.
- Embedding all 6 command logics inline: Violates DRY, creates maintenance burden when upstream commands change.

## R3: How should the clarify step work in auto mode?

**Decision**: The SKILL.md instructs the LLM to run `/speckit.clarify` and, for each question it would normally ask the user, instead select the recommended option (or generate a best-practice answer) and proceed immediately. Each auto-resolved decision is documented in the spec's Assumptions section.

**Rationale**: The existing clarify command already generates recommended options with reasoning for each question. The auto skill simply tells the LLM to accept those recommendations instead of waiting for user input.

**Alternatives considered**:
- Skipping clarify entirely: Misses the value of the ambiguity scan and assumption documentation.
- Running clarify in a special "non-interactive mode": Would require modifying the clarify command itself, violating the orchestration-only design.

## R4: How should the analyze step's auto-fix work?

**Decision**: When `/speckit.analyze` reports inconsistencies, the SKILL.md instructs the LLM to read each inconsistency, determine which artifact(s) need updating, make the fix, and re-run analyze once. If issues persist after the second run, the pipeline halts.

**Rationale**: The analyze command is read-only by design -- it reports issues but doesn't fix them. The auto skill adds the fix behavior at the orchestration level: the LLM reads the report, edits the files, then re-validates.

**Alternatives considered**:
- Modifying the analyze command to support auto-fix: Breaks separation of concerns. Analyze should remain a pure audit tool.
- Skipping analyze: Loses the quality gate between planning and implementation.

## R5: How should progress reporting work?

**Decision**: The SKILL.md includes a step template that the LLM outputs before and after each command invocation. Format: a markdown header with step number, name, and status (starting/completed/failed).

**Rationale**: Since the SKILL.md controls the LLM's behavior, it can prescribe output formatting at each transition point. This requires no tooling -- it's just instructions for what to print.

**Alternatives considered**:
- A helper script that manages a progress file: Overengineering for what is essentially output formatting.
- No progress reporting: Violates FR-004 and makes long-running pipelines opaque.

## R6: How should failure handling and resume work?

**Decision**: On failure, the SKILL.md instructs the LLM to: (1) output the failed step name and error, (2) list all artifacts generated so far, (3) output the exact `/speckit.*` command the user can run to resume. No automatic retry beyond what each individual command already does.

**Rationale**: Since artifacts are written to disk by each command as it runs, they're naturally preserved on failure. The LLM just needs to report the resume point. The existing speckit commands are idempotent -- re-running them on existing artifacts either updates or no-ops.

**Alternatives considered**:
- Automatic retry with backoff: The failure modes are typically content/quality issues, not transient errors. Retrying the same input would produce the same failure.
- Pipeline state file for resume: Unnecessary -- the LLM can detect which artifacts exist and determine the resume point from the file system.

## R7: Should the skill use a precondition-checking helper script?

**Decision**: No dedicated helper script. The SKILL.md instructs the LLM to run `git status --porcelain` and `git branch` to check preconditions (clean working directory, correct branch) before starting.

**Rationale**: These are two simple git commands. A helper script would add a file with no meaningful abstraction benefit. The existing `create-new-feature.sh` script (called by `/speckit.specify`) already handles branch creation.

**Alternatives considered**:
- A `preflight.sh` script: Would only contain 2-3 lines of git commands. Not worth the additional file.
