# Research: Force Push with Confirmation

## R1: Current Step 4 and Step 6 interaction

**Decision**: Keep Step 4's pre-squash warning about force-push intact. Modify Step 6 to offer execution instead of just reminding.

**Rationale**: Step 4 warns users *before* squashing that a force-push will be needed — this is important so they can decline the squash entirely if they don't want to rewrite pushed history. Step 6 is the *post-squash* action point where the actual push happens. These serve different purposes and both should remain.

**Alternatives considered**:
- Merge warning and push into a single step: Rejected because the user needs the warning before committing to the squash, and the push can only happen after.
- Move all force-push handling to Step 4: Rejected because the push must happen after the squash completes.

## R2: How the agent should execute the force push

**Decision**: The SKILL.md should instruct the agent to run `git push --force-with-lease` directly after user confirmation, capture both stdout and stderr, and report the result.

**Rationale**: The agent already executes bash commands throughout the skill (running `squash.sh`, `git commit`, `git log`). Adding `git push --force-with-lease` follows the same pattern. `--force-with-lease` is safe because it refuses to push if the remote branch has been updated by someone else since the last fetch.

**Alternatives considered**:
- Have the agent construct a more specific command like `git push --force-with-lease origin branch-name`: Unnecessary because git uses the upstream tracking branch by default, and the helper script already confirmed `HAS_UPSTREAM=true`.

## R3: Failure handling approach

**Decision**: On push failure, display the full error output, reassure the user that the local squash is intact (the commit was already created), and show the manual command for retry.

**Rationale**: The local squash (soft-reset + commit) is already complete before the push step. A push failure doesn't affect local state. The user may need to resolve the issue (network, permissions, force-with-lease rejection) before retrying, so providing the manual command lets them retry at their convenience.

**Alternatives considered**:
- Automatic retry: Rejected because push failures typically require user intervention (network fix, permission change, or deciding how to handle someone else's commits).
