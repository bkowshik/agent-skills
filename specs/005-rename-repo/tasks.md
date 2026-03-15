# Tasks: Rename Repository from git-skills to agent-skills

**Input**: Design documents from `/specs/005-rename-repo/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md

**Tests**: Not requested — no test tasks included.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: No setup needed — this feature modifies existing files only. No new files, dependencies, or infrastructure.

*(No tasks in this phase)*

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: No foundational work needed — all changes are independent text replacements in existing files.

*(No tasks in this phase)*

---

## Phase 3: User Story 1 - Update all in-repo references from git-skills to agent-skills (Priority: P1) 🎯 MVP

**Goal**: Replace "git-skills" with "agent-skills" in all user-facing files so the repository identity is consistent with the new name.

**Independent Test**: Run `grep -r "git-skills" --include="*.md" --include="*.json" . | grep -v "specs/"` — must return zero results.

### Implementation for User Story 1

- [x] T001 [P] [US1] Replace "git-skills" with "agent-skills" in README.md (heading and install command — 2 occurrences)
- [x] T002 [P] [US1] Replace "git-skills" with "agent-skills" in CLAUDE.md (heading — 1 occurrence)
- [x] T003 [P] [US1] Replace "git-skills" with "agent-skills" in .specify/memory/constitution.md (heading — 1 occurrence)
- [x] T004 [P] [US1] Replace "git-skills" with "agent-skills" in skills/squash-commits/README.md (install command — 1 occurrence)
- [x] T005 [P] [US1] Replace "git-skills" with "agent-skills" in skills/learning-log/README.md (install command — 1 occurrence)
- [x] T006 [P] [US1] Replace "git-skills" with "agent-skills" in skills-lock.json (source field — 1 occurrence)
- [x] T007 [US1] Verify rename completeness: run grep to confirm zero "git-skills" matches in user-facing files

**Checkpoint**: All user-facing files now say "agent-skills". Verification grep returns zero matches.

---

## Phase 4: User Story 2 - Preserve historical accuracy in past specs (Priority: P2)

**Goal**: Ensure spec files for features 001, 002, and 003 are NOT modified — historical references to "git-skills" must remain intact.

**Independent Test**: Run `git diff specs/001-squash-commits/ specs/002-fix-readme-command/ specs/003-fix-script-path/` — must show no changes.

### Implementation for User Story 2

- [x] T008 [US2] Verify historical specs are untouched: run `git diff` on specs/001-*, specs/002-*, specs/003-* directories to confirm zero modifications

**Checkpoint**: Historical spec files confirmed unchanged.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Final validation across both user stories.

- [x] T009 Run quickstart.md validation steps to confirm full rename correctness

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: Skipped — no setup needed
- **Phase 2 (Foundational)**: Skipped — no foundational work needed
- **Phase 3 (US1)**: Can start immediately — all tasks are independent file edits
- **Phase 4 (US2)**: Can run in parallel with US1 — it's a verification-only phase
- **Phase 5 (Polish)**: Depends on US1 and US2 completion

### User Story Dependencies

- **User Story 1 (P1)**: No dependencies — 6 independent file edits
- **User Story 2 (P2)**: No dependencies on US1 — purely a verification step

### Within Each User Story

- US1: All 6 edit tasks (T001–T006) can run in parallel, then T007 verifies
- US2: Single verification task (T008)

### Parallel Opportunities

- T001 through T006 can ALL run in parallel (different files, no dependencies)
- US1 implementation and US2 verification can run in parallel

---

## Parallel Example: User Story 1

```bash
# Launch all 6 file edits in parallel:
Task: "Replace git-skills in README.md"
Task: "Replace git-skills in CLAUDE.md"
Task: "Replace git-skills in .specify/memory/constitution.md"
Task: "Replace git-skills in skills/squash-commits/README.md"
Task: "Replace git-skills in skills/learning-log/README.md"
Task: "Replace git-skills in skills-lock.json"

# Then verify:
Task: "Verify rename completeness with grep"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Execute T001–T006 in parallel (all file edits)
2. Run T007 (verification grep)
3. **STOP and VALIDATE**: Zero "git-skills" in user-facing files
4. Ready for PR

### Incremental Delivery

1. Complete US1 (T001–T007) → All references renamed
2. Complete US2 (T008) → Historical preservation confirmed
3. Complete Polish (T009) → Full quickstart validation
4. PR ready for merge

---

## Notes

- All [P] tasks edit different files — safe to run in parallel
- T007 and T008 are verification-only tasks (read, not write)
- After merging, the user must manually rename the GitHub repository in Settings
- The specs/005-rename-repo/ directory itself is excluded from renaming since it documents the rename feature
