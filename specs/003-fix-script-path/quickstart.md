# Quickstart: Fix Script Path Resolution

## What to change

One file: `.agents/skills/squash-commits/SKILL.md`

## How to change it

Replace every occurrence of `scripts/squash.sh` with `{{SKILL_DIR}}/scripts/squash.sh`.

There are 9 occurrences — all inline text references and code block commands.

## How to verify

1. Read the updated SKILL.md and confirm no bare `scripts/squash.sh` references remain
2. Invoke `/squash-commits` on a branch with multiple commits
3. Confirm the helper script is found and executed on the first attempt (no "file not found" errors)
