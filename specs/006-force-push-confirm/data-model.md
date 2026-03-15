# Data Model: Force Push with Confirmation

No new data entities are introduced by this feature.

## Existing Data Used

The feature relies on data already produced by the `squash.sh` helper script:

- **HAS_UPSTREAM** (boolean): Whether the current branch tracks a remote branch. Determines if the force-push prompt is shown.
- **Backup ref** (string): The backup ref path created during squash (e.g., `refs/backup/squash-commits/feature/branch-name`). Referenced in recovery guidance if push fails.

## State Flow

```
Squash complete
    │
    ├── HAS_UPSTREAM = false → Show success summary (no push prompt)
    │
    └── HAS_UPSTREAM = true
         │
         ├── Show collaborator warning
         ├── Ask user to confirm force push
         │
         ├── User confirms
         │    ├── Push succeeds → Show success with push confirmation
         │    └── Push fails → Show error, confirm local intact, show manual command
         │
         └── User declines → Show manual command as reference
```
