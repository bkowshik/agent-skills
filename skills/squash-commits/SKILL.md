---
name: squash-commits
description: >-
  Squash all commits on the current branch into a single commit with a
  coherent, synthesized commit message. Use when you want to clean up branch
  history before merging — combines multiple small commits (WIP, fixes,
  iterations) into one meaningful commit. Trigger keywords: squash commits,
  combine commits, consolidate commits, clean branch history, collapse commits.
---

# Squash Commits

Combine all commits on the current branch into a single commit with a
meaningful, synthesized commit message. This cleans up branch history before
merging so reviewers see one clear commit instead of dozens of WIP saves.

## How it works

The helper script at `{{SKILL_DIR}}/scripts/squash.sh` handles git operations (pre-flight
checks, base branch detection, backup, soft-reset). You handle the commit
message synthesis and user interaction.

## Workflow

### Step 1: Gather information

Run the helper script in dry-run mode to collect commit data without modifying
anything:

```bash
{{SKILL_DIR}}/scripts/squash.sh --dry-run
```

The output contains:
- `BASE_BRANCH` — the detected base branch
- `COMMIT_COUNT` — number of commits to squash
- `HAS_MERGE_COMMITS` — whether merge commits are present
- `HAS_UPSTREAM` — whether the branch has been pushed
- `COMMITS` section — each commit (short hash + message)
- `COMMIT MESSAGES` section — full message body of each commit
- `TRAILERS` section — deduplicated `Co-authored-by` and `Signed-off-by` trailers

If the script exits with an error, relay the error message to the user and
stop. Common errors: dirty working tree, detached HEAD, only one commit ahead.

### Step 2: Synthesize the commit message

Read all the commit messages from the dry-run output. Your job is to
understand the overall intent of the changes and write a single, coherent
commit message — not a mechanical list or concatenation of the originals.

Good synthesis means:
- Capture what the combined changes accomplish as a whole
- Remove noise (WIP, fixup, typo fixes, "oops") that doesn't add meaning
- Use the same voice and style as the project's existing commits
- Keep it concise — a short summary line, optionally followed by a body

If the TRAILERS section contains any trailers, append them at the end of the
commit message (after a blank line). These carry attribution and compliance
information that should not be dropped.

### Step 3: Show the preview

Present the user with a clear preview before any changes are made. Because
squashing rewrites history, showing exactly what will happen reduces mistakes
and builds confidence. Display:

- **Base branch**: the detected base branch name and merge-base commit
- **Commits to squash**: count and list (short hash + original message for each)
- **Proposed message**: the full synthesized commit message you wrote
- **Force-push needed**: yes/no based on whether the branch has been pushed
- **Merge commits warning**: if merge commits are present, warn that squashing
  will flatten them

Then ask the user to confirm or decline. If they decline, stop — no changes
are made.

### Step 4: Handle pushed branches

If `HAS_UPSTREAM=true`, the branch has been pushed to a remote. After
squashing, the user will need to force-push (`git push --force-with-lease`)
because the branch history has been rewritten. Warn the user about this and
ask for explicit confirmation before proceeding. This matters because
collaborators who have pulled the branch will see diverged history.

### Step 5: Execute the squash

Run the helper script in execute mode (without `--dry-run`):

```bash
{{SKILL_DIR}}/scripts/squash.sh
```

This creates a backup ref and runs `git reset --soft` to the merge-base. All
changes remain staged.

Then create the commit with the synthesized message:

```bash
git commit -m "<synthesized message with trailers>"
```

### Step 6: Confirm success

After the commit, show the user:
- The new single commit (run `git log --oneline -1`)
- The backup ref location (from the script output)
- The recovery command: `git reset --hard <backup-ref>`
- If the branch was pushed: remind them to run `git push --force-with-lease`

## Specifying a different base branch

If the script cannot auto-detect the base branch (none of `main`, `master`,
`develop` exist), it will exit with an error asking you to specify one. Ask
the user which branch to use, then re-run with:

```bash
{{SKILL_DIR}}/scripts/squash.sh --dry-run --base-branch <name>
```

And for execution:

```bash
{{SKILL_DIR}}/scripts/squash.sh --base-branch <name>
```

Always confirm the detected base branch in the preview so the user can correct
it before proceeding.

### Example: branch off `develop`

If a user is on `feature/login` branched off `develop`:

```bash
{{SKILL_DIR}}/scripts/squash.sh --dry-run --base-branch develop
```

The script finds the merge-base between `develop` and HEAD, lists only the
commits on `feature/login`, and the rest of the workflow proceeds identically.

## Edge cases

- **Dirty working tree**: The script refuses to run. Tell the user to commit
  or stash their changes first — a reset with uncommitted changes can lose work.
- **Detached HEAD**: The script refuses. Tell the user that squashing requires
  being on a branch.
- **Single commit ahead**: The script reports nothing to squash. Inform the
  user and stop.
- **Merge commits in history**: The script detects and reports them. Warn the
  user that squashing will flatten merge commits into a single linear commit.
  Ask for confirmation before proceeding.
- **Already pushed**: Covered in Step 4 above. Warn about force-push.
- **Diverged base** (base branch has new commits since the branch was created):
  The soft-reset approach handles this correctly by design. It only affects the
  branch's own commits — the merge-base stays the same regardless of new
  commits on the base branch. No rebase is performed.

## Example

A developer has a branch `feature/add-search` with 4 commits off `main`:

```
abc1234 WIP: search endpoint skeleton
def5678 Add query parsing and validation
ghi9012 Fix typo in search query parser
jkl3456 Add pagination to search results

Co-authored-by: Alice <alice@example.com>
```

Running the skill:

1. `{{SKILL_DIR}}/scripts/squash.sh --dry-run` shows 4 commits, base branch `main`,
   no merge commits, not pushed.

2. You synthesize: "Add search endpoint with query parsing, validation,
   and paginated results"

3. Preview shown to user:
   ```
   Base branch: main (merge-base: 789abcd)
   Commits to squash: 4
     abc1234 WIP: search endpoint skeleton
     def5678 Add query parsing and validation
     ghi9012 Fix typo in search query parser
     jkl3456 Add pagination to search results

   Proposed message:
     Add search endpoint with query parsing, validation, and paginated results

     Co-authored-by: Alice <alice@example.com>

   Force-push needed: No
   ```

4. User confirms.

5. `{{SKILL_DIR}}/scripts/squash.sh` creates backup at `refs/backup/squash-commits/feature/add-search`
   and soft-resets to merge-base.

6. `git commit -m "Add search endpoint with query parsing, validation, and paginated results\n\nCo-authored-by: Alice <alice@example.com>"` creates the single commit.

7. Result: branch has 1 commit ahead of `main`, identical file state, backup
   ref available for recovery.
