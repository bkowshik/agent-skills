# Feature Specification: Speckit Auto

**Feature Branch**: `008-speckit-auto`
**Created**: 2026-03-26
**Status**: Draft
**Input**: User description: "I want to go through all the github spec-kit steps one by one in the recommended order, including the optional ones and have the LLM choose the recommended step and keep moving forward. That way, I just have to start the processes with a command which will in turn call all the speckit commands starting with specify so that I am not interrupted until the final implementation is ready."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Hands-Free Full Pipeline Execution (Priority: P1)

A user has a feature idea and wants to go from description to working implementation without manually invoking each speckit step. They type a single command with their feature description and walk away. The system automatically runs specify, clarify (auto-resolving ambiguities), plan, tasks, analyze, and implement in sequence, making informed decisions at each step without pausing for user input. No git commits are made during execution.

**Why this priority**: This is the core value proposition -- eliminating the manual orchestration of 6 sequential commands and the wait time between each step.

**Independent Test**: Can be fully tested by running the single command with a simple feature description and verifying that all speckit artifacts (spec.md, plan.md, tasks.md, and implementation code) are generated without any user prompts in between and that no git commits are created.

**Acceptance Scenarios**:

1. **Given** a user is on the main branch with no pending changes, **When** they run the auto-pipeline command with a feature description, **Then** the system creates a feature branch, generates all speckit artifacts in order, and completes implementation without requesting user input at any intermediate step. No git commits are made.
2. **Given** the auto-pipeline is running the clarify step, **When** the spec contains ambiguities, **Then** the system makes informed choices (using context, industry standards, and the project constitution) instead of asking the user, and documents those choices in the spec's Assumptions section.
3. **Given** the auto-pipeline completes all steps, **When** the user reviews the output, **Then** they find all standard speckit artifacts in the feature's specs directory and implementation code in the source tree, all as uncommitted files.

---

### User Story 2 - Progress Visibility During Execution (Priority: P2)

A user launches the auto-pipeline and wants to know what step the system is currently on and whether earlier steps completed successfully, without having to manually check files.

**Why this priority**: Without progress visibility, the user has no way to know if the pipeline is stuck, failed, or progressing normally during what could be a lengthy execution.

**Independent Test**: Can be tested by running the pipeline and observing that each step transition is reported with a clear status message indicating which step completed and which is starting next.

**Acceptance Scenarios**:

1. **Given** the auto-pipeline is running, **When** a step completes successfully, **Then** the system outputs a status message indicating the completed step, its result, and the next step about to begin.
2. **Given** the auto-pipeline is running, **When** a step fails or produces warnings, **Then** the system outputs the failure/warning details and either recovers automatically or halts with a clear explanation of what went wrong.

---

### User Story 3 - Graceful Failure and Partial Recovery (Priority: P3)

A user's auto-pipeline run encounters a failure at an intermediate step (e.g., the plan step fails validation after maximum retries). The system halts cleanly, preserves all artifacts generated up to that point, and tells the user exactly where it stopped and how to resume manually.

**Why this priority**: Failures are inevitable in a multi-step pipeline. Users need confidence that a failure won't lose work and that they can pick up where the pipeline left off.

**Independent Test**: Can be tested by simulating a failure condition at a specific step and verifying that prior artifacts are preserved, the failure is clearly reported, and the user is told which speckit command to run next to resume.

**Acceptance Scenarios**:

1. **Given** the auto-pipeline has completed specify, clarify, and plan, **When** the tasks step fails, **Then** all previously generated artifacts (spec.md, plan.md, research.md, etc.) remain intact on disk and the user is told to run `/speckit.tasks` to retry from that point.
2. **Given** a step fails, **When** the system reports the failure, **Then** the message includes the step name, the error details, and the exact command to resume from that step.

---

### Edge Cases

- What happens when the feature description is empty or too vague to produce a meaningful spec? The system should refuse to start and ask the user to provide a more detailed description.
- What happens when the analyze step finds critical inconsistencies between spec, plan, and tasks? The system generates fix recommendations for each inconsistency and applies them automatically (updating the affected artifacts). If inconsistencies persist after one auto-fix pass, the system halts and reports the remaining issues.
- What happens if the user's working directory has uncommitted changes when the pipeline starts? The system should warn the user and halt before creating a new branch, to avoid mixing unrelated changes.
- What happens if a previous auto-pipeline run for the same feature already exists? The system should detect the existing branch/artifacts and refuse to overwrite, directing the user to resume or start fresh.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a single command entry point that accepts a feature description and runs the full speckit pipeline (specify, clarify, plan, tasks, analyze, implement) without intermediate user prompts.
- **FR-002**: System MUST execute speckit steps in the recommended order: specify -> clarify -> plan -> tasks -> analyze -> implement.
- **FR-003**: System MUST auto-resolve all clarification questions during the clarify step by making informed choices based on project context, industry standards, and the project constitution, documenting each decision in the spec's Assumptions section.
- **FR-004**: System MUST output a progress indicator at each step transition showing which step completed and which step is starting next.
- **FR-005**: System MUST halt execution if any step fails after its built-in retry logic is exhausted, preserving all artifacts generated by prior steps.
- **FR-006**: System MUST report on failure: the failed step name, error details, and the specific speckit command the user can run to resume from that point.
- **FR-007**: System MUST validate preconditions before starting: clean working directory (no uncommitted changes) and no existing branch/artifacts for the same feature.
- **FR-008**: System MUST pass the original feature description through to the specify step unchanged.
- **FR-009**: System MUST produce all standard speckit artifacts for each step (spec.md, plan.md, research.md, data-model.md, contracts/, quickstart.md, tasks.md) as applicable, plus implementation code.
- **FR-010**: System MUST provide a final summary upon successful completion listing all generated artifacts, the feature branch name, and the implementation status.
- **FR-012**: System MUST NOT create any git commits during pipeline execution. All artifacts are written to disk but remain uncommitted.
- **FR-011**: When the analyze step detects inconsistencies, the system MUST generate a fix recommendation for each issue and apply it automatically by updating the affected artifacts (spec.md, plan.md, or tasks.md). If inconsistencies remain after one auto-fix pass, the system MUST halt and report the unresolved issues.

### Key Entities

- **Pipeline Run**: Represents a single end-to-end execution of the auto-pipeline, tracking current step, status, feature description, branch name, and generated artifacts.
- **Pipeline Step**: Represents one speckit command in the sequence, with its name, execution order, status (pending/running/completed/failed), and output artifacts.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can go from feature description to working implementation by issuing a single command with no intermediate input required.
- **SC-002**: The pipeline completes all 6 steps for a typical feature description (2-3 sentences) in a single uninterrupted session.
- **SC-003**: On failure at any step, 100% of previously generated artifacts are preserved and accessible.
- **SC-004**: The final output includes a clear summary that allows the user to understand what was built and where all artifacts are located.
- **SC-005**: Users report at least 80% reduction in manual orchestration effort compared to running each speckit command individually.

## Clarifications

### Session 2026-03-26

- Q: What should happen when the analyze step detects inconsistencies? → A: Generate fix recommendations for each inconsistency and apply them automatically (updating affected artifacts). Halt only if issues persist after one auto-fix pass.
- Q: What should the pipeline's "done" state be? → A: Pipeline ends when `/speckit.implement` completes successfully. No git commits are made during pipeline execution.
- Q: How should the pipeline invoke each speckit step? → A: Implemented as a standard skill in this repository (SKILL.md + optional helper scripts in `skills/speckit-auto/`), following the same pattern as `squash-commits` and `learning-log`.

## Assumptions

- The user's environment has all speckit prerequisites installed and configured (git, Claude Code with speckit skills).
- The project has a valid `.specify/` directory with all required templates and scripts.
- The project constitution (`.specify/memory/constitution.md`) exists and provides sufficient context for auto-resolving clarification questions.
- The auto-pipeline is implemented as a standard repository skill (`skills/speckit-auto/SKILL.md` + optional helper scripts), following the same pattern as `squash-commits` and `learning-log`.
- The skill orchestrates existing speckit commands rather than reimplementing their logic.
- The `taskstoissues` step is excluded from the pipeline since it creates external GitHub issues, which is a side-effect the user may want to control separately.
- No git commits are created during pipeline execution. All generated artifacts (design docs and implementation code) remain uncommitted for user review.
