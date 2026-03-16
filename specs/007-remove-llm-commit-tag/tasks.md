# Tasks: Remove LLM Attribution from Squashed Commit Messages

**Input**: Design documents from `/specs/007-remove-llm-commit-tag/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md

**Tests**: Not requested in spec — test tasks omitted. Validation via eval scenarios (constitution Principle IV).

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Include exact file paths in descriptions

---

## Phase 1: User Story 1 - Clean Squashed Commit Message (Priority: P1) MVP

**Goal**: Ensure the squash-commits skill produces commit messages with no LLM attribution — neither from original commit trailers nor added by the agent itself.

**Independent Test**: Run the squash-commits skill on a branch with multiple commits (some containing LLM Co-Authored-By trailers). Verify the resulting squashed commit message has no LLM attribution lines.

### Implementation for User Story 1

- [x] T001 [US1] Add LLM trailer filtering to the trailer extraction pipeline in skills/squash-commits/scripts/squash.sh — after the existing `sort -u | sed '/^$/d'` on line 181, pipe through `grep -v -i -E` with patterns for known LLM/bot emails: `noreply@anthropic.com`, `noreply@openai.com`, `noreply@google.com`, `noreply@github.com`, `users.noreply.github.com`
- [x] T002 [US1] Add explicit no-attribution instruction in skills/squash-commits/SKILL.md — in Step 2 (Synthesize the commit message), add a clear directive telling the agent: do NOT add your own name, Co-Authored-By trailer, or any other attribution identifying you as an AI tool to the commit message

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently. Running the squash-commits skill should produce clean commit messages with zero LLM attribution.

---

## Phase 2: User Story 2 - Preserve Existing Human Trailers (Priority: P2)

**Goal**: Ensure human-authored trailers (Co-authored-by, Signed-off-by) from original commits survive the LLM filtering and appear in the squashed commit.

**Independent Test**: Create a branch with commits containing both human Co-authored-by trailers and LLM Co-Authored-By trailers. Run the squash-commits skill. Verify human trailers are preserved and LLM trailers are removed.

### Implementation for User Story 2

- [x] T003 [US2] Verify the grep filter in skills/squash-commits/scripts/squash.sh correctly passes through human trailers — ensure the filter patterns are specific enough that trailers like `Co-authored-by: Jane Doe <jane@example.com>` and `Signed-off-by: John Smith <john@company.com>` are NOT matched by the exclusion patterns
- [x] T004 [US2] Update the SKILL.md example in skills/squash-commits/SKILL.md — modify the existing example (line 196–228) to show that human trailers are preserved while no LLM attribution appears in the final commit message

**Checkpoint**: Both user stories should now work independently. Human trailers preserved, LLM trailers filtered.

---

## Phase 3: Polish & Cross-Cutting Concerns

**Purpose**: Final validation and cleanup

- [x] T005 Review the complete skills/squash-commits/SKILL.md for consistency — ensure no other sections reference or imply LLM attribution should be added to commit messages
- [x] T006 Validate the updated skills/squash-commits/scripts/squash.sh by tracing the trailer pipeline end-to-end — confirm the grep filter handles edge cases: all-LLM trailers (result: empty), mixed trailers (result: human only), no trailers (result: unchanged)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (US1)**: No dependencies — can start immediately
- **Phase 2 (US2)**: Depends on T001 completion (the grep filter must exist before verifying it passes human trailers)
- **Phase 3 (Polish)**: Depends on Phases 1 and 2

### User Story Dependencies

- **User Story 1 (P1)**: Independent — T001 and T002 modify different files and can run in parallel
- **User Story 2 (P2)**: T003 depends on T001 (verifies the filter); T004 is independent of T003

### Within Each User Story

- US1: T001 (script) and T002 (SKILL.md) are parallel — different files
- US2: T003 (verify filter) then T004 (update example) are sequential

### Parallel Opportunities

- T001 and T002 can run in parallel (different files: squash.sh vs SKILL.md)
- T005 and T006 can run in parallel (review vs validation, different concerns)

---

## Parallel Example: User Story 1

```bash
# Launch both US1 tasks together (different files):
Task: "Add LLM trailer filtering in skills/squash-commits/scripts/squash.sh"
Task: "Add no-attribution instruction in skills/squash-commits/SKILL.md"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete T001 + T002 in parallel
2. **STOP and VALIDATE**: Run squash-commits on a test branch, verify no LLM attribution
3. If clean, MVP is done

### Incremental Delivery

1. T001 + T002 (parallel) → US1 complete → validate
2. T003 → T004 → US2 complete → validate human trailers preserved
3. T005 + T006 (parallel) → Polish complete → final validation

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Total: 6 tasks across 3 phases
- This is a small, focused change — 2 files modified (squash.sh, SKILL.md)
- Commit after each task or logical group
