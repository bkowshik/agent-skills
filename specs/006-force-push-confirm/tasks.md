# Tasks: Force Push with Confirmation

**Input**: Design documents from `/specs/006-force-push-confirm/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md

**Tests**: Not requested. Eval-first validation per constitution principle IV.

**Organization**: Tasks are grouped by user story. All changes target a single file (`skills/squash-commits/SKILL.md`), so parallelism within phases is limited.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup

**Purpose**: No setup needed. The file to modify already exists and no new dependencies are introduced.

*(No tasks in this phase)*

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Adjust Step 4 to remove the redundant "ask for explicit confirmation before proceeding" about force-push, since the actual confirmation now happens in Step 6. Step 4 should still warn about force-push being needed, but not ask for a separate confirmation that duplicates Step 6's new prompt.

- [x] T001 Update Step 4 in skills/squash-commits/SKILL.md to keep the force-push warning but remove the explicit confirmation request, since confirmation moves to Step 6

**Checkpoint**: Step 4 warns about force-push but no longer asks for a separate confirmation about it

---

## Phase 3: User Story 1 - Automatic Force Push After Squash (Priority: P1) 🎯 MVP

**Goal**: When a pushed branch is squashed, the agent asks the user to confirm force-push and executes `git push --force-with-lease` on confirmation. On decline, shows the manual command.

**Independent Test**: Squash commits on a pushed branch. Verify the skill prompts to force-push after squash completes, executes on confirmation, and shows manual command on decline.

### Implementation for User Story 1

- [x] T002 [US1] Rewrite Step 6 in skills/squash-commits/SKILL.md to add the force-push confirmation flow when `HAS_UPSTREAM=true`: warn about collaborators seeing diverged history, ask user to confirm, execute `git push --force-with-lease` on confirmation, show push result to user
- [x] T003 [US1] Add decline path to Step 6 in skills/squash-commits/SKILL.md: if user declines force push, skip pushing and display `git push --force-with-lease` as a reference command (preserving current behavior)

**Checkpoint**: Pushed branches get the full confirm-and-push flow; declining shows the manual command

---

## Phase 4: User Story 2 - Skip Force Push Prompt for Unpushed Branches (Priority: P1)

**Goal**: Unpushed branches see no force-push prompt — the workflow is unchanged from current behavior.

**Independent Test**: Squash commits on a local-only branch. Verify no force-push prompt appears.

### Implementation for User Story 2

- [x] T004 [US2] Ensure Step 6 in skills/squash-commits/SKILL.md explicitly branches on `HAS_UPSTREAM`: when false, show only the success summary (new commit, backup ref, recovery command) with no mention of force-push

**Checkpoint**: Unpushed branches complete squash with no force-push prompt

---

## Phase 5: User Story 3 - Force Push Failure Handling (Priority: P2)

**Goal**: If `git push --force-with-lease` fails, display the error, reassure the user their local squash is intact, and provide the manual command for retry.

**Independent Test**: Simulate a push failure (e.g., protected branch). Verify error is shown with recovery guidance.

### Implementation for User Story 3

- [x] T005 [US3] Add failure handling to the force-push execution path in Step 6 of skills/squash-commits/SKILL.md: if push fails, display the error output, state that the local squash commit is intact, show the backup ref and recovery command, and provide `git push --force-with-lease` for manual retry

**Checkpoint**: Push failures show clear error with local-intact reassurance and retry command

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Update the example section and edge cases to reflect the new behavior

- [x] T006 Update the Example section in skills/squash-commits/SKILL.md to show the force-push confirmation flow for a pushed branch scenario
- [x] T007 Update the "Already pushed" bullet in the Edge cases section of skills/squash-commits/SKILL.md to reference the new confirmation-and-execute flow instead of just "Warn about force-push"

---

## Dependencies & Execution Order

### Phase Dependencies

- **Foundational (Phase 2)**: No dependencies — can start immediately
- **User Story 1 (Phase 3)**: Depends on Phase 2 (Step 4 adjustment)
- **User Story 2 (Phase 4)**: Depends on Phase 3 (Step 6 rewrite must exist before adding the unpushed branch path)
- **User Story 3 (Phase 5)**: Depends on Phase 3 (failure handling is added to the push execution path created in US1)
- **Polish (Phase 6)**: Depends on Phases 3-5

### User Story Dependencies

- **User Story 1 (P1)**: Depends on T001 (Step 4 adjustment). Core change.
- **User Story 2 (P1)**: Depends on T002/T003 (Step 6 must be rewritten first to add the `HAS_UPSTREAM` branching)
- **User Story 3 (P2)**: Depends on T002 (push execution path must exist before adding failure handling)

### Within Each User Story

- All tasks are sequential (same file, same section)

### Parallel Opportunities

- T004 and T005 can run in parallel after T002/T003 complete (they modify different branches of the `HAS_UPSTREAM` conditional, but since they're in the same file section, sequential is safer)

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete T001: Adjust Step 4
2. Complete T002-T003: Rewrite Step 6 with confirmation flow
3. **STOP and VALIDATE**: Test on a pushed branch — confirm, decline, verify behavior

### Incremental Delivery

1. T001 → Step 4 adjusted
2. T002-T003 → Force-push confirmation works for pushed branches (MVP!)
3. T004 → Unpushed branches unaffected
4. T005 → Failure handling in place
5. T006-T007 → Documentation updated

---

## Notes

- All 7 tasks modify the same file: `skills/squash-commits/SKILL.md`
- Sequential execution recommended due to single-file constraint
- Commit after each phase for clean history
- Total scope: ~20-30 lines modified/added in SKILL.md
