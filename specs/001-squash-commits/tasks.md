# Tasks: Squash Commits

**Input**: Design documents from `/specs/001-squash-commits/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md

**Tests**: Not requested in the feature specification. No test tasks included.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Skill directory**: `skills/squash-commits/`
- **Skill file**: `skills/squash-commits/SKILL.md`
- **Helper script**: `skills/squash-commits/scripts/squash.sh`

## Phase 1: Setup

**Purpose**: Create the skill directory structure per the Agent Skills Specification.

- [x] T001 Create skill directory structure at `skills/squash-commits/` with `scripts/` subdirectory
- [x] T002 Create SKILL.md with required frontmatter (`name: squash-commits`, `description`) at `skills/squash-commits/SKILL.md` — leave body empty for now

**Checkpoint**: Directory structure exists, SKILL.md passes `skills-ref validate`

---

## Phase 2: Foundational (Helper Script)

**Purpose**: The bash helper script handles all git operations. All user stories depend on this script existing.

- [x] T003 Write `skills/squash-commits/scripts/squash.sh` with the following capabilities:
  - Accept arguments: `--base-branch <name>` (optional), `--dry-run` (preview only), `--backup-ref <path>` (override backup location)
  - Pre-flight checks: refuse if working tree is dirty, HEAD is detached, or not on a branch
  - Base branch detection: find merge-base against `main`, `master`, `develop` candidates; exit with error if ambiguous (agent will ask user)
  - Count commits ahead of base; exit with message if only 1 commit
  - Detect merge commits in the branch history (`git log --merges`); report them in output so the agent can warn the user
  - Detect if branch has been pushed (check for upstream tracking branch)
  - In `--dry-run` mode: print commit list, trailers, and push status, then exit
  - In execute mode: create backup ref at `refs/backup/squash-commits/<branch-name>`, run `git reset --soft <merge-base>`, exit (agent handles the commit)
  - Extract and deduplicate git trailers (`Co-authored-by`, `Signed-off-by`) from all branch commits, print to stdout
  - Include error messages with recovery instructions referencing the backup ref
  - Make the script executable (`chmod +x`)

**Checkpoint**: Script runs standalone — `./squash.sh --dry-run` on a test branch shows correct output

---

## Phase 3: User Story 1 — Squash all branch commits into one (Priority: P1) MVP

**Goal**: The core squash operation works end-to-end when an agent follows the SKILL.md instructions.

**Independent Test**: Create a branch with 3+ commits off `main`, activate the skill, verify 1 commit remains with synthesized message and identical tree.

- [x] T004 [US1] Write the SKILL.md body at `skills/squash-commits/SKILL.md` with instructions for the core squash workflow:
  - Step 1: Run `scripts/squash.sh --dry-run` to gather commit list, trailers, and push status
  - Step 2: Read the commit messages from the dry-run output
  - Step 3: Synthesize a single coherent commit message from the individual messages (explain to the agent: understand the overall intent, remove WIP noise, write a clean summary — not a mechanical list)
  - Step 4: Append deduplicated trailers from the script output to the synthesized message
  - Step 5: Show the user a preview: commits being squashed, proposed message, base branch
  - Step 6: Ask for confirmation (if declined, stop — no changes made)
  - Step 7: If branch was pushed, warn about force-push requirement and ask for additional confirmation
  - Step 8: Run `scripts/squash.sh` (execute mode) to create backup ref and soft-reset
  - Step 9: Run `git commit` with the synthesized message
  - Step 10: Confirm success — show new commit, backup ref location, and recovery command
  - Include an end-to-end example showing the full agent behavior
- [x] T005 [US1] Add edge case handling instructions to SKILL.md at `skills/squash-commits/SKILL.md`:
  - Dirty working tree: tell user to commit or stash first
  - Detached HEAD: tell user squashing requires a branch
  - Single commit ahead: inform user there is nothing to squash
  - Merge commits in history: warn user and ask for confirmation
  - Already pushed: warn about force-push (covered in main flow but reinforce in edge cases section)
  - Diverged base (base has new commits): document that soft-reset handles this correctly by design — the squash only affects branch commits, not base updates

**Checkpoint**: An agent following SKILL.md can squash commits on a standard feature branch off `main`

---

## Phase 4: User Story 2 — Preview before squashing (Priority: P2)

**Goal**: The preview step is clear and informative enough that users feel confident before confirming.

**Independent Test**: Run the skill, verify the preview shows all commit messages, the proposed consolidated message, the base branch, and push status — without modifying any state.

- [x] T006 [US2] Refine the preview section in SKILL.md at `skills/squash-commits/SKILL.md` to instruct the agent to display:
  - Base branch name and merge-base commit
  - Number of commits to squash
  - Each original commit (short hash + message)
  - The proposed consolidated message (full text)
  - Whether a force-push will be needed
  - Clear confirm/decline prompt
  - Explain to the agent why previewing matters: squashing rewrites history, showing the user what will happen reduces mistakes

**Checkpoint**: Preview output is informative and no git state is modified until user confirms

---

## Phase 5: User Story 3 — Handle non-standard base branches (Priority: P3)

**Goal**: The skill works when the branch was created off `develop`, `release/*`, or any other base — not just `main`.

**Independent Test**: Create a branch off `develop` with 3 commits, run the skill, verify it detects `develop` as the base and squashes correctly.

- [x] T007 [US3] Add base branch override instructions to SKILL.md at `skills/squash-commits/SKILL.md`:
  - When the script cannot determine the base branch (ambiguous or no candidates found), instruct the agent to ask the user which branch to use
  - Pass the user-specified branch to the script via `--base-branch <name>`
  - Instruct the agent to confirm the detected base branch in the preview so the user can correct it before proceeding
  - Add an example scenario showing a branch off `develop`

**Checkpoint**: Skill works with `develop`, `release/*`, and user-specified base branches

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final quality pass across the entire skill.

- [x] T008 [P] Review SKILL.md at `skills/squash-commits/SKILL.md` for token budget — verify body is under 5000 tokens (~500 lines); if over, move reference material to `skills/squash-commits/references/`
- [x] T009 [P] Verify `description` frontmatter in `skills/squash-commits/SKILL.md` states both what the skill does and when to use it, with trigger keywords (squash, combine commits, clean branch history, consolidate commits)
- [x] T010 Run quickstart.md validation: follow the steps in `specs/001-squash-commits/quickstart.md` end-to-end on a test repo and verify all commands work. Include a test with a branch containing 50 commits to validate SC-005 (under 5 seconds).

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 (directory must exist)
- **User Stories (Phase 3+)**: All depend on Phase 2 (script must exist)
  - US2 and US3 refine SKILL.md written in US1, so execute sequentially: US1 → US2 → US3
- **Polish (Phase 6)**: Depends on all user stories being complete

### Within Each User Story

- T004 before T005 (core flow before edge cases)
- T006 refines T004's preview section
- T007 adds to T004's base branch handling

### Parallel Opportunities

- T001 and T002 are sequential (directory before file)
- T008 and T009 can run in parallel (different concerns, same file but different sections)
- T010 runs last (needs everything complete)

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (script)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test with an AI coding tool on a real branch
5. Skill is usable at this point

### Incremental Delivery

1. Setup + Foundational → Script works standalone
2. User Story 1 → Core squash works (MVP)
3. User Story 2 → Preview is polished
4. User Story 3 → Non-standard base branches supported
5. Polish → Token budget, description quality, quickstart validation

---

## Notes

- This skill has only 2 files to create: SKILL.md and squash.sh
- US2 and US3 modify SKILL.md (same file as US1), so they run sequentially
- The agent synthesizes the commit message — the script only provides the raw commit messages and trailers
- No test tasks included since the spec did not request them; validation is via manual eval scenarios per the Eval-First principle
