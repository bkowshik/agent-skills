# Data Model: Squash Commits

This skill operates on git repository state rather than application data. The "data model" is the set of git objects and refs the skill reads and writes.

## Entities

### Branch Commits

The set of commits between the merge-base and the current branch tip.

- **Identified by**: `git log --oneline <merge-base>..<branch-tip>`
- **Attributes**: SHA, author, date, message, trailers
- **Lifecycle**: Read-only during the skill. After squash, these commits become unreachable (but recoverable via backup ref).

### Consolidated Commit

The single commit created after squashing.

- **Parent**: The merge-base commit (same parent as the first branch commit had)
- **Tree**: Identical to the original branch tip tree (no file changes)
- **Message**: Synthesized by the agent from all branch commit messages
- **Trailers**: Deduplicated trailers collected from all branch commits

### Backup Ref

A git ref preserving the original branch tip.

- **Path**: `refs/backup/squash-commits/<branch-name>`
- **Points to**: The original branch tip SHA before squashing
- **Created**: Before the squash operation
- **Deleted**: Never (user manages cleanup manually)

## State Transitions

```
[Branch with N commits]
    → Pre-flight checks pass
    → Backup ref created
    → git reset --soft <merge-base>
    → Agent synthesizes message from N commit messages
    → git commit with synthesized message + deduplicated trailers
    → [Branch with 1 commit, same tree]
```

## Relationships

- **Backup ref → Original branch tip**: One-to-one. Each squash creates exactly one backup ref.
- **Consolidated commit → Branch commits**: Many-to-one. N branch commits become 1 consolidated commit.
- **Consolidated commit tree = Original branch tip tree**: Invariant. The file state never changes.
