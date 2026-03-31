# Tasks: Review PR Comments

**Input**: Design documents from `/specs/009-review-pr-comments/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md

**Tests**: Not requested — no test tasks included.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create skill directory structure and initialize files

- [x] T001 Create skill directory structure: `skills/review-pr-comments/`, `skills/review-pr-comments/scripts/`
- [x] T002 [P] Create SKILL.md skeleton with YAML frontmatter (`name: review-pr-comments`, `description` with trigger keywords) in `skills/review-pr-comments/SKILL.md`
- [x] T003 [P] Create fetch-comments.sh skeleton with argument parsing, usage help, and `set -euo pipefail` in `skills/review-pr-comments/scripts/fetch-comments.sh`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Preflight checks and comment fetching — MUST be complete before any user story work

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T004 Implement preflight checks in `skills/review-pr-comments/scripts/fetch-comments.sh`: verify `gh` CLI installed, `gh auth status` passes, current directory is a git repo, verify user has push access to the PR branch (e.g., `git push --dry-run` or check repo permissions via `gh`), detect PR number from current branch via `gh pr view --json number` or accept as argument
- [x] T005 Implement `--fetch` mode in `skills/review-pr-comments/scripts/fetch-comments.sh`: GraphQL query to fetch `reviewThreads` with `isResolved`, `isOutdated`, `comments` (including `databaseId`, `body`, `author.login`, `path`, `line`), filter out resolved/outdated threads, output structured JSON to stdout. Note: the GraphQL `reviewThreads` query inherently returns only inline review comments — top-level issue comments are excluded by design (satisfies FR-001 scope)
- [x] T006 Implement GraphQL pagination in `skills/review-pr-comments/scripts/fetch-comments.sh`: use `gh api graphql --paginate` with `$endCursor` variable to handle PRs with many review threads
- [x] T007 Add SKILL.md overview and "How it works" section explaining the helper script pattern and workflow states (Preflight → Fetch → Classify → Preview → Execute → Reply → Push) in `skills/review-pr-comments/SKILL.md`

**Checkpoint**: Helper script can fetch and output all active review threads as JSON. SKILL.md has overview.

---

## Phase 3: User Story 1 — Triage and Address PR Review Comments (Priority: P1) 🎯 MVP

**Goal**: Classify each review comment as "required change", "suggestion", or "pushback", then make code changes for required items and draft rationale for pushback items.

**Independent Test**: Invoke the skill on a PR with mixed comment types (bug, style nit, scope creep). Verify each is classified correctly, code changes are committed (one per comment), and pushback rationale is drafted.

### Implementation for User Story 1

- [x] T008 [US1] Add SKILL.md workflow step "Fetch and display comments": call `fetch-comments.sh --fetch`, parse JSON output, display each thread (author, file:line, body snippet) in a numbered list in `skills/review-pr-comments/SKILL.md`
- [x] T009 [US1] Add SKILL.md workflow step "Classify comments": for each thread, classify as `required_change`, `suggestion`, or `pushback` based on comment content; present classification table to user (comment summary, category, proposed action) as an informational display in `skills/review-pr-comments/SKILL.md`. Note: this is a read-only display; interactive approval/override is handled by T016-T017 in US3
- [x] T010 [US1] Add SKILL.md workflow step "Execute code changes": for each `required_change` comment, read the referenced file, apply the fix, create one commit per comment with a concise descriptive message (no AI attribution); for `suggestion` comments, either apply or draft rationale in `skills/review-pr-comments/SKILL.md`
- [x] T011 [US1] Add SKILL.md workflow step "Draft pushback rationale": for each `pushback` comment, draft a professional rationale explaining why the suggestion was not incorporated, with alternatives where applicable in `skills/review-pr-comments/SKILL.md`
- [x] T012 [US1] Add SKILL.md edge case handling: zero unresolved comments (exit gracefully), stale comments referencing deleted/moved code (flag and ask user), `gh` not authenticated (provide setup instructions) in `skills/review-pr-comments/SKILL.md`

**Checkpoint**: Skill can fetch comments, classify them, make code changes, and draft pushback rationale. One commit per addressed comment.

---

## Phase 4: User Story 2 — Post Inline Replies to Each Comment Thread (Priority: P1)

**Goal**: Post an inline reply directly on each reviewer's comment thread describing the action taken.

**Independent Test**: After processing comments, verify each thread receives a reply via `gh api` and no top-level summary comment is posted.

### Implementation for User Story 2

- [x] T013 [US2] Implement `--reply` mode in `skills/review-pr-comments/scripts/fetch-comments.sh`: accept `--comment-id <id>` and `--body <text>`, post reply via `POST /repos/{owner}/{repo}/pulls/{number}/comments/{comment_id}/replies` using `gh api`
- [x] T014 [US2] Add SKILL.md workflow step "Draft inline replies": for each classified thread, compose a reply describing the action taken (code changed with commit ref, suggestion declined with rationale, or follow-up noted) in `skills/review-pr-comments/SKILL.md`
- [x] T015 [US2] Add SKILL.md workflow step "Post inline replies": after user confirmation, call `fetch-comments.sh --reply` for each thread; report success/failure for each reply in `skills/review-pr-comments/SKILL.md`

**Checkpoint**: Each review thread receives an inline reply. No top-level summary comment is posted.

---

## Phase 4b: Push Changes (Core Flow — FR-010)

**Purpose**: Push committed changes to the remote branch. This is part of the core workflow regardless of whether US3 (preview/confirm) is implemented.

- [x] T015b [US1] Add SKILL.md workflow step "Push changes": after all code changes are committed and replies are posted, prompt the user to confirm, then run `git push` to update the remote branch. Report success or failure in `skills/review-pr-comments/SKILL.md`

**Note**: When US3 (Phase 5) is implemented, T018 wraps this push step in the broader confirmation flow. Without US3, this task ensures changes still get pushed.

---

## Phase 5: User Story 3 — Preview and Confirm Before Committing (Priority: P2)

**Goal**: Show user a preview of all proposed actions and allow overrides before any commits or replies are posted.

**Independent Test**: Verify the skill pauses for confirmation before each commit and before posting replies. Override a classification and confirm the action changes accordingly.

### Implementation for User Story 3

- [x] T016 [US3] Add SKILL.md workflow step "Present action plan": after classification, display a structured preview of all threads with their classification, proposed action, and draft reply; ask user to approve, modify, or skip individual items in `skills/review-pr-comments/SKILL.md`
- [x] T017 [US3] Add SKILL.md workflow step "Handle user overrides": if user changes a classification, update the proposed action and re-draft the reply for that thread; loop until user approves the full plan in `skills/review-pr-comments/SKILL.md`
- [x] T018 [US3] Add SKILL.md workflow step "Confirm before push": after all commits are made, show a summary of commits and ask user to confirm before running `git push`; after push, show commit summary and ask to confirm before posting replies in `skills/review-pr-comments/SKILL.md`

**Checkpoint**: User has full control — can review, override, and confirm every action before it happens.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Documentation and final validation

- [x] T019 [P] Create user-facing README.md with installation, usage, prerequisites, and examples in `skills/review-pr-comments/README.md`
- [x] T020 [P] Add "Specifying a PR" section to SKILL.md: document how the skill identifies the PR (current branch default, explicit PR number, or URL argument) in `skills/review-pr-comments/SKILL.md`
- [x] T021 Add "Example" section to SKILL.md with a complete worked scenario (PR with 3 comments: one bug fix, one style suggestion accepted, one scope creep pushed back) in `skills/review-pr-comments/SKILL.md`
- [x] T022 Run quickstart.md validation against the completed skill in `specs/009-review-pr-comments/quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion — BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - US1 and US2 can proceed in parallel (US1 builds SKILL.md workflow, US2 builds reply mechanism)
  - **Push (Phase 4b)**: Depends on US1 and US2 — ensures changes are pushed as part of core flow
  - US3 depends on US1 and US2 (preview/confirm wraps around the actions from both; T018 supersedes T015b when US3 is active)
- **Polish (Phase 6)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) — no dependencies on other stories
- **User Story 2 (P1)**: Can start after Foundational (Phase 2) — no dependencies on other stories
- **User Story 3 (P2)**: Depends on US1 and US2 — adds confirmation flow around existing actions

### Within Each User Story

- SKILL.md workflow steps should be added in order (fetch → classify → execute → reply)
- Helper script modes (`--fetch`, `--reply`) should be implemented before the SKILL.md steps that reference them

### Parallel Opportunities

- T002 and T003 can run in parallel (different files)
- T019 and T020 can run in parallel (different files)
- US1 (T008–T012) and US2 (T013–T015) can proceed in parallel since US1 writes to SKILL.md workflow steps and US2 primarily adds a script mode + later SKILL.md steps

---

## Parallel Example: Foundational Phase

```bash
# After T004 completes (preflight checks), T005 and T006 are sequential (pagination builds on fetch)
# T007 can run in parallel with T005-T006 (different file: SKILL.md vs fetch-comments.sh)
Task: "Add SKILL.md overview section"  # T007 — SKILL.md
Task: "Implement --fetch mode"          # T005 — fetch-comments.sh
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL — blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test classification and code changes on a real PR
5. Skill is usable at this point — comments are classified, changes committed

### Incremental Delivery

1. Complete Setup + Foundational → Helper script fetches comments
2. Add User Story 1 → Classify & fix → Test independently (MVP!)
3. Add User Story 2 → Inline replies posted → Test independently
4. Add User Story 3 → Preview & confirm flow → Test independently
5. Polish → README, examples, quickstart validation

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- The SKILL.md is the primary deliverable — most tasks add sections to it incrementally
- The fetch-comments.sh helper encapsulates all `gh` API calls — SKILL.md never calls `gh` directly
