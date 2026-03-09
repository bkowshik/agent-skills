# Quickstart: Squash Commits Skill

## Install

```bash
npx skills add bkowshik/git-skills/squash-commits
```

Or copy the `skills/squash-commits/` directory into your project's `.skills/` directory.

## Usage

From a feature branch with multiple commits, ask your AI coding tool:

> Squash all my commits on this branch into one.

The agent will:
1. Detect the base branch and list the commits to squash
2. Show you a preview of the proposed consolidated message
3. Ask for confirmation
4. Create a backup ref and perform the squash

## Verify

After squashing:

```bash
# Should show exactly 1 commit ahead of base
git log --oneline main..HEAD

# File state should be unchanged
git diff HEAD~1..HEAD  # shows the full diff of the single commit

# Backup ref exists for recovery
git show refs/backup/squash-commits/<branch-name>
```

## Recovery

If something went wrong:

```bash
git reset --hard refs/backup/squash-commits/<branch-name>
```

This restores the branch to its original state with all commits intact.
