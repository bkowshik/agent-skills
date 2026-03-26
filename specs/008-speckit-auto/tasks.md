# Tasks: Speckit Auto

**Input**: Design documents from `/specs/008-speckit-auto/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, quickstart.md

**Tests**: Not requested. Validation is eval-first per constitution (behavioral scenarios).

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the skill directory and SKILL.md skeleton with frontmatter

- [x] T001 Create skill directory at skills/speckit-auto/
- [x] T002 Create SKILL.md skeleton with YAML frontmatter (name, description, trigger keywords) and top-level section headings at skills/speckit-auto/SKILL.md

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Write the precondition checking and step invocation patterns that all pipeline steps depend on

**CRITICAL**: No user story work can begin until this phase is complete

- [x] T003 Write the "When to use" section explaining the skill's purpose and when to invoke it at skills/speckit-auto/SKILL.md
- [x] T004 Write the "User input" section documenting that the command takes a feature description as its argument at skills/speckit-auto/SKILL.md
- [x] T005 Write the "Precondition checks" workflow section instructing the LLM to verify clean working directory (`git status --porcelain`) and no existing branch/artifacts before starting at skills/speckit-auto/SKILL.md

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Hands-Free Full Pipeline Execution (Priority: P1) MVP

**Goal**: Single command runs all 6 speckit steps (specify, clarify, plan, tasks, analyze, implement) end-to-end without user prompts

**Independent Test**: Run `/speckit-auto "Add a greeting endpoint"` on a clean repo and verify all speckit artifacts plus implementation code are generated without any user prompts

### Implementation for User Story 1

- [x] T006 [US1] Write Step 1 (Specify) section instructing the LLM to invoke `/speckit.specify` with the user's feature description passed through unchanged at skills/speckit-auto/SKILL.md
- [x] T007 [US1] Write Step 2 (Clarify) section instructing the LLM to invoke `/speckit.clarify` and auto-resolve all questions by selecting the recommended option or generating a best-practice answer, documenting each decision in the spec's Assumptions section at skills/speckit-auto/SKILL.md
- [x] T008 [US1] Write Step 3 (Plan) section instructing the LLM to invoke `/speckit.plan` at skills/speckit-auto/SKILL.md
- [x] T009 [US1] Write Step 4 (Tasks) section instructing the LLM to invoke `/speckit.tasks` at skills/speckit-auto/SKILL.md
- [x] T010 [US1] Write Step 5 (Analyze) section instructing the LLM to invoke `/speckit.analyze`, and if inconsistencies are found, generate fix recommendations, apply them to the affected artifacts, then re-run analyze once; halt if issues persist at skills/speckit-auto/SKILL.md
- [x] T011 [US1] Write Step 6 (Implement) section instructing the LLM to invoke `/speckit.implement` with no git commits at skills/speckit-auto/SKILL.md
- [x] T012 [US1] Write the "Completion summary" section instructing the LLM to output a final report listing all generated artifacts, the feature branch name, and implementation status at skills/speckit-auto/SKILL.md

**Checkpoint**: At this point, User Story 1 should be fully functional - the skill can run all 6 steps end-to-end

---

## Phase 4: User Story 2 - Progress Visibility During Execution (Priority: P2)

**Goal**: User sees clear status messages at each step transition showing which step completed and which is starting next

**Independent Test**: Run the pipeline and observe that each step transition outputs a status header with step number, name, and result

### Implementation for User Story 2

- [x] T013 [US2] Add a "Progress reporting" subsection defining the step transition output template (markdown header with step number/total, name, and status) that the LLM must output before and after each step at skills/speckit-auto/SKILL.md
- [x] T014 [US2] Update each of the 6 step sections (T006-T011) to include the prescribed progress output format at the start ("Starting...") and end ("complete" or "failed") of each step at skills/speckit-auto/SKILL.md

**Checkpoint**: At this point, the pipeline outputs clear progress at every step transition

---

## Phase 5: User Story 3 - Graceful Failure and Partial Recovery (Priority: P3)

**Goal**: On failure at any step, the pipeline halts cleanly, preserves all artifacts, and reports the exact resume command

**Independent Test**: Trigger a failure condition and verify prior artifacts are preserved, the error is reported with step name and details, and the resume command is shown

### Implementation for User Story 3

- [x] T015 [US3] Add a "Failure handling" section instructing the LLM on halt behavior: output the failed step name, error details, list of preserved artifacts, and the exact `/speckit.*` command to resume at skills/speckit-auto/SKILL.md
- [x] T016 [US3] Update each of the 6 step sections (T006-T011) to include failure detection: if the step produces an error or fails validation, invoke the failure handling instructions instead of proceeding to the next step at skills/speckit-auto/SKILL.md

**Checkpoint**: All user stories should now be independently functional

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Edge cases, documentation, and skill registration

- [x] T017 [P] Write the "Edge cases" section covering: empty/vague description, uncommitted changes, existing branch/artifacts, analyze auto-fix failure at skills/speckit-auto/SKILL.md
- [x] T018 [P] Write the "Example" section with a complete worked example showing a pipeline run from invocation to completion summary (reference quickstart.md scenarios) at skills/speckit-auto/SKILL.md
- [x] T019 [P] Create README.md with installation, usage, requirements, and recovery instructions at skills/speckit-auto/README.md
- [x] T020 Update skills-lock.json to register the new speckit-auto skill with source and computed hash at skills-lock.json
- [x] T021 Review complete SKILL.md for agent-agnostic language (no tool-specific APIs), self-contained instructions, and consistency with the Agent Skills Specification format at skills/speckit-auto/SKILL.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - US1 (Phase 3) must complete before US2 (Phase 4) since progress reporting augments the step sections
  - US1 (Phase 3) must complete before US3 (Phase 5) since failure handling augments the step sections
  - US2 and US3 can proceed in parallel after US1 completes
- **Polish (Phase 6)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Depends on US1 completion (augments the step sections written in US1)
- **User Story 3 (P3)**: Depends on US1 completion (augments the step sections written in US1). Can run in parallel with US2.

### Within Each User Story

- Steps must be written in pipeline order (specify → clarify → plan → tasks → analyze → implement)
- Each step section depends on understanding the previous step's output

### Parallel Opportunities

- T017, T018, T019 can all run in parallel (different files or independent sections)
- US2 and US3 can run in parallel after US1 completes (they modify different aspects of the step sections)

---

## Parallel Example: User Story 1

```text
# Steps must be written sequentially (each references the prior step's output):
Task T006: Write Step 1 (Specify) section
Task T007: Write Step 2 (Clarify) section
Task T008: Write Step 3 (Plan) section
Task T009: Write Step 4 (Tasks) section
Task T010: Write Step 5 (Analyze) section
Task T011: Write Step 6 (Implement) section
Task T012: Write Completion summary section
```

## Parallel Example: Polish Phase

```text
# These can all run in parallel (different files/independent sections):
Task T017: Edge cases section in SKILL.md
Task T018: Example section in SKILL.md
Task T019: README.md (separate file)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T002)
2. Complete Phase 2: Foundational (T003-T005)
3. Complete Phase 3: User Story 1 (T006-T012)
4. **STOP and VALIDATE**: Test the skill by running `/speckit-auto "simple feature"` -- verify all 6 steps execute
5. The pipeline works end-to-end at this point

### Incremental Delivery

1. Complete Setup + Foundational → Skeleton ready
2. Add User Story 1 → Test end-to-end pipeline → MVP!
3. Add User Story 2 → Test progress reporting visible at each step
4. Add User Story 3 → Test failure halts cleanly with resume info
5. Add Polish → Edge cases, example, README, registration
6. Each story adds behavioral quality without breaking the core pipeline

---

## Notes

- All implementation is Markdown authoring -- no compiled code or runtime dependencies
- The single deliverable file is skills/speckit-auto/SKILL.md (~200-300 lines)
- Secondary file is skills/speckit-auto/README.md (~30-40 lines)
- No helper scripts needed -- orchestration is purely instructional
- Validate against constitution principles after each phase checkpoint
