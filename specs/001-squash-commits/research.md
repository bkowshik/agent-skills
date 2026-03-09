# Research: Squash Commits

## Git squash mechanisms

**Decision**: Use `git reset --soft` to the merge-base, then `git commit` with the synthesized message.

**Rationale**: `git reset --soft <merge-base>` moves the branch pointer back to the merge-base while keeping all changes staged. A single `git commit` then creates one commit with the exact same tree as the original branch tip. This is simpler and more predictable than interactive rebase (`git rebase -i`), which requires editor interaction and can fail on conflicts during replay. Since we want to preserve the exact file state (not replay commits), soft reset is the right tool.

**Alternatives considered**:
- `git rebase -i` with squash/fixup: Requires interactive editor or scripted `GIT_SEQUENCE_EDITOR` manipulation. Can fail if commits conflict when replayed. Overkill for "collapse everything into one."
- `git merge --squash`: Only works when merging one branch into another, not for squashing in place on the current branch.
- `git commit-tree`: Low-level plumbing that creates a commit object directly. Works but requires manual ref updates and is harder to follow in skill instructions.

## Base branch detection

**Decision**: Check the merge-base of the current branch against a priority-ordered list of candidate base branches (`main`, `master`, `develop`). Use the candidate with the most recent merge-base. If no candidates exist or results are ambiguous, ask the user.

**Rationale**: Most repositories use `main` or `master`. Checking merge-base against candidates is more reliable than parsing `git reflog` or tracking config, which vary across setups. The merge-base approach works regardless of how the branch was created.

**Alternatives considered**:
- `git config branch.<name>.merge`: Only set if the branch was created with `--track` or pushed with `-u`. Not reliable for feature branches.
- Parsing `git log --graph`: Complex and error-prone.

## Backup ref strategy

**Decision**: Create a ref at `refs/backup/squash-commits/<branch-name>` pointing to the original branch tip before squashing.

**Rationale**: Git refs are lightweight (just a SHA pointer) and persist until explicitly deleted. Using a namespaced path under `refs/backup/` keeps them organized and avoids polluting the branch namespace. Recovery is a simple `git reset --hard refs/backup/squash-commits/<branch-name>`.

**Alternatives considered**:
- Git stash: Stashes are for working tree changes, not branch history. Semantically wrong.
- Tags: Would show up in `git tag` output and could confuse users. Refs under `refs/backup/` are invisible to normal commands.

## Pushed branch detection

**Decision**: Check if the current branch has a remote tracking branch using `git rev-parse --abbrev-ref @{upstream}`. If it exists and the remote ref is reachable, the branch has been pushed.

**Rationale**: This is the standard way to check if a branch tracks a remote. If the upstream exists, the branch was pushed at some point, and squashing will require a force-push.

## Consolidated message synthesis

**Decision**: The agent (LLM) synthesizes the consolidated message by reading all original commit messages and producing a coherent summary. The skill instructions guide this by telling the agent to read the commit messages, understand the overall intent, and write a single message — not a mechanical concatenation.

**Rationale**: Since this is a SKILL.md consumed by an AI agent, the agent itself is the best tool for message synthesis. Unlike a bash script that would just concatenate, the agent can understand context, remove WIP noise, and produce a clean summary.

**Alternatives considered**:
- Script-based concatenation: Produces noisy output ("WIP", "fix typo", "oops") that defeats the purpose of squashing.
- Templated format (numbered list, bullets): Mechanical and doesn't capture intent. User explicitly rejected this approach during spec clarification.

## Git trailers handling

**Decision**: Extract trailers from all original commits using `git log --format='%(trailers:key=Co-authored-by,key=Signed-off-by,unfold,valueonly)'` (or similar), deduplicate, and append to the consolidated message.

**Rationale**: Trailers carry attribution and compliance information. Dropping them silently can break DCO sign-off requirements and contribution tracking. Deduplication avoids repetition when the same trailer appears in multiple commits.
