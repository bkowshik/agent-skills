# Tasks: Fix Script Path Resolution in Squash-Commits Skill

**Input**: Design documents from `/specs/003-fix-script-path/`
**Prerequisites**: plan.md, spec.md, research.md, quickstart.md

**Tests**: Not requested — no test tasks included.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: No setup needed — this is a single-file edit to an existing file.

(No tasks in this phase)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: No foundational infrastructure needed — the file to edit already exists.

(No tasks in this phase)

---

## Phase 3: User Story 1 - Skill Finds Script on First Attempt (Priority: P1) 🎯 MVP

**Goal**: Replace all hardcoded `scripts/squash.sh` references with `{{SKILL_DIR}}/scripts/squash.sh` so the skill loader resolves the path correctly on the first attempt.

**Independent Test**: Invoke `/squash-commits` on a branch with multiple commits and verify the script is found on the first attempt with no "file not found" errors.

### Implementation for User Story 1

- [x] T001 [US1] Replace inline reference to `scripts/squash.sh` in "How it works" section of `.agents/skills/squash-commits/SKILL.md`
- [x] T002 [US1] Replace all code block commands (`scripts/squash.sh --dry-run`, `scripts/squash.sh`, `scripts/squash.sh --base-branch`) with `{{SKILL_DIR}}/scripts/squash.sh` equivalents in `.agents/skills/squash-commits/SKILL.md`
- [x] T003 [US1] Replace inline references to `scripts/squash.sh` in the Example section of `.agents/skills/squash-commits/SKILL.md`

**Checkpoint**: All 9 occurrences of `scripts/squash.sh` replaced. No bare `scripts/squash.sh` references remain in SKILL.md.

---

## Phase 4: User Story 2 - SKILL.md Uses Portable Path Placeholders (Priority: P1)

**Goal**: Verify that every script path reference in SKILL.md uses the `{{SKILL_DIR}}` placeholder and no hardcoded paths remain.

**Independent Test**: Read the updated SKILL.md and confirm every code block and inline reference uses `{{SKILL_DIR}}/scripts/squash.sh`.

### Implementation for User Story 2

- [x] T004 [US2] Verify no remaining bare `scripts/squash.sh` references exist in `.agents/skills/squash-commits/SKILL.md` (search for `scripts/squash.sh` without `{{SKILL_DIR}}` prefix)
- [x] T005 [US2] Verify `{{SKILL_DIR}}/scripts/squash.sh` resolves to a valid path when `{{SKILL_DIR}}` is substituted with `.agents/skills/squash-commits`

**Checkpoint**: All path references verified as portable. SKILL.md is LLM-agnostic.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Final validation

- [x] T006 Run quickstart.md validation — invoke `/squash-commits` on a test branch and confirm first-attempt success

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 3 (US1)**: No dependencies — can start immediately
- **Phase 4 (US2)**: Depends on Phase 3 completion (verification of the changes)
- **Phase 5 (Polish)**: Depends on Phase 4 completion

### User Story Dependencies

- **User Story 1 (P1)**: No dependencies — edit the file
- **User Story 2 (P1)**: Depends on US1 — verifies the edits are correct and complete

### Within User Story 1

- T001, T002, T003 can be executed as a single edit pass (all modify the same file)
- Recommended: do all replacements in one pass to avoid partial states

### Parallel Opportunities

- T001, T002, T003 target different sections of the same file — execute sequentially in a single edit pass for consistency
- T004 and T005 are independent verification steps that can run in parallel

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 3: Replace all 9 path references (T001-T003)
2. **STOP and VALIDATE**: Invoke `/squash-commits` and confirm first-attempt success
3. Done — this is a complete, shippable fix

### Full Delivery

1. Complete T001-T003 (replacements)
2. Complete T004-T005 (verification)
3. Complete T006 (end-to-end validation)

---

## Notes

- All tasks modify or verify a single file: `.agents/skills/squash-commits/SKILL.md`
- The helper script `.agents/skills/squash-commits/scripts/squash.sh` is NOT modified
- Total of 9 `scripts/squash.sh` occurrences to replace (lines 19, 31, 91, 118, 124, 135, 173, 198 in current SKILL.md)
- Commit after T003 (all replacements done)
