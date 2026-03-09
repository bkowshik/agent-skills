# squash-commits

Combine all commits on the current branch into a single commit with a coherent, synthesized commit message. Cleans up branch history before merging.

## Install

```bash
npx skills add bkowshik/git-skills/squash-commits
```

## Usage

From a feature branch with multiple commits, ask your AI coding tool:

> Squash all my commits on this branch into one.

The agent will:
1. Detect the base branch and list commits to squash
2. Show a preview of the proposed consolidated message
3. Ask for confirmation
4. Create a backup ref and perform the squash

## Requirements

- Git 2.20+
- macOS or Linux

## Recovery

If something went wrong after squashing:

```bash
git reset --hard refs/backup/squash-commits/<branch-name>
```
