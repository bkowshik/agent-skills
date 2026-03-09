# Tasks: Fix README Install Command

**Input**: Design documents from `/specs/002-fix-readme-command/`
**Prerequisites**: plan.md, spec.md, research.md, quickstart.md

**Tests**: Not requested — no test tasks included.

**Organization**: Single user story, single file change.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: No setup needed — this is a single-file documentation edit.

*No tasks in this phase.*

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: No foundational work needed.

*No tasks in this phase.*

---

## Phase 3: User Story 1 - Install skills from README instructions (Priority: P1) 🎯 MVP

**Goal**: Add a working install command to the README so users can install skills by copying a single command.

**Independent Test**: Copy the command from the rendered README, run `npx skills add bkowshik/git-skills` in a terminal, and verify the skill installs successfully.

### Implementation for User Story 1

- [x] T001 [US1] Add Installation section with `npx skills add bkowshik/git-skills` command to README.md

**Checkpoint**: README contains a visible Installation section with the correct command. Running the command installs the squash-commits skill successfully.

---

## Phase 4: Polish & Cross-Cutting Concerns

**Purpose**: Verify the change renders correctly.

- [x] T002 Run quickstart.md validation against README.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **User Story 1 (Phase 3)**: No dependencies — can start immediately
- **Polish (Phase 4)**: Depends on T001 completion

### Parallel Opportunities

- None — this is a single sequential task.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete T001: Add Installation section to README.md
2. **STOP and VALIDATE**: Verify command works by running it
3. Commit and push

### Notes

- Single file change: `README.md`
- The Installation section goes between the repo description and the `## Skills` heading
- Command format: `npx skills add bkowshik/git-skills` (no trailing slash, no skill subdirectory)
