# Quickstart: Force Push with Confirmation

## What changes

The squash-commits skill's Step 6 is updated so that when a branch has been pushed to a remote, the agent:

1. Warns about collaborators seeing diverged history
2. Asks the user to confirm the force push
3. Executes `git push --force-with-lease` on confirmation
4. Reports success or failure with appropriate guidance

Previously, Step 6 just told the user to run the command manually.

## Files to modify

1. `skills/squash-commits/SKILL.md` — Update Step 6 and adjust Step 4

## How to test

1. Create a branch, make multiple commits, push to remote
2. Run the squash skill
3. Confirm the squash
4. Verify the force-push prompt appears with collaborator warning
5. Confirm the force push and verify it executes successfully
6. Repeat with declining the force push — verify manual command is shown
7. Test on an unpushed branch — verify no force-push prompt appears
