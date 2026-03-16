#!/usr/bin/env bash
set -euo pipefail

# squash.sh — Helper script for the squash-commits skill.
# Handles pre-flight checks, base branch detection, backup, and soft-reset.
# The agent handles commit message synthesis and the final git commit.

usage() {
  cat <<'EOF'
Usage: squash.sh [OPTIONS]

Options:
  --dry-run              Preview mode: show what would be squashed, then exit
  --base-branch <name>   Use this branch as the base instead of auto-detecting
  --backup-ref <path>    Override the backup ref path (default: refs/backup/squash-commits/<branch>)
  -h, --help             Show this help message

In dry-run mode, prints commit list, trailers, merge commit warnings, and
push status without modifying anything.

In execute mode, creates a backup ref and runs git reset --soft to the
merge-base. The agent is responsible for running git commit afterward.
EOF
}

# --- Argument parsing ---

DRY_RUN=false
BASE_BRANCH=""
BACKUP_REF_OVERRIDE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --base-branch)
      BASE_BRANCH="$2"
      shift 2
      ;;
    --backup-ref)
      BACKUP_REF_OVERRIDE="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

# --- Pre-flight checks ---

# Check we're in a git repo
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "ERROR: Not a git repository." >&2
  exit 1
fi

# Check for detached HEAD
if ! git symbolic-ref -q HEAD >/dev/null 2>&1; then
  echo "ERROR: HEAD is detached. Squashing requires a branch." >&2
  echo "Run 'git checkout <branch-name>' first." >&2
  exit 1
fi

# Check for dirty working tree
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
  echo "ERROR: Working tree has uncommitted changes." >&2
  echo "Commit or stash your changes first — a reset with dirty state can lose work." >&2
  exit 1
fi

# Check for staged but uncommitted changes
if ! git diff --cached --quiet 2>/dev/null; then
  echo "ERROR: Index has staged but uncommitted changes." >&2
  echo "Commit or unstage your changes first." >&2
  exit 1
fi

# Get current branch name
CURRENT_BRANCH=$(git symbolic-ref --short HEAD)

# --- Base branch detection ---

detect_base_branch() {
  local candidates=("main" "master" "develop")
  local best_candidate=""
  local best_merge_base=""
  local best_distance=-1

  for candidate in "${candidates[@]}"; do
    # Check if candidate branch exists (local or remote)
    if git rev-parse --verify "$candidate" >/dev/null 2>&1 || \
       git rev-parse --verify "origin/$candidate" >/dev/null 2>&1; then

      # Use local branch if it exists, otherwise remote
      local ref="$candidate"
      if ! git rev-parse --verify "$candidate" >/dev/null 2>&1; then
        ref="origin/$candidate"
      fi

      local merge_base
      merge_base=$(git merge-base "$ref" HEAD 2>/dev/null) || continue

      # Count commits from merge-base to HEAD (fewer = closer = better match)
      local distance
      distance=$(git rev-list --count "$merge_base..HEAD" 2>/dev/null) || continue

      if [[ "$best_distance" -eq -1 ]] || [[ "$distance" -lt "$best_distance" ]]; then
        best_distance=$distance
        best_candidate=$candidate
        best_merge_base=$merge_base
      fi
    fi
  done

  if [[ -z "$best_candidate" ]]; then
    echo "ERROR: Could not detect base branch. None of main, master, develop exist." >&2
    echo "Re-run with --base-branch <name> to specify the base branch." >&2
    exit 1
  fi

  echo "$best_candidate"
}

if [[ -n "$BASE_BRANCH" ]]; then
  # Validate the provided base branch exists
  if ! git rev-parse --verify "$BASE_BRANCH" >/dev/null 2>&1 && \
     ! git rev-parse --verify "origin/$BASE_BRANCH" >/dev/null 2>&1; then
    echo "ERROR: Base branch '$BASE_BRANCH' does not exist." >&2
    exit 1
  fi
else
  BASE_BRANCH=$(detect_base_branch)
fi

# Resolve the actual ref (prefer local, fall back to remote)
BASE_REF="$BASE_BRANCH"
if ! git rev-parse --verify "$BASE_BRANCH" >/dev/null 2>&1; then
  BASE_REF="origin/$BASE_BRANCH"
fi

# Find merge-base
MERGE_BASE=$(git merge-base "$BASE_REF" HEAD 2>/dev/null) || {
  echo "ERROR: Could not find merge-base between '$BASE_BRANCH' and HEAD." >&2
  exit 1
}

# --- Commit analysis ---

# Count commits ahead of base
COMMIT_COUNT=$(git rev-list --count "$MERGE_BASE..HEAD")

if [[ "$COMMIT_COUNT" -le 1 ]]; then
  echo "Nothing to squash: branch has $COMMIT_COUNT commit(s) ahead of $BASE_BRANCH."
  exit 0
fi

# Detect merge commits
MERGE_COMMITS=$(git log --merges --oneline "$MERGE_BASE..HEAD" 2>/dev/null || true)
HAS_MERGE_COMMITS=false
if [[ -n "$MERGE_COMMITS" ]]; then
  HAS_MERGE_COMMITS=true
fi

# Detect if branch has been pushed
HAS_UPSTREAM=false
if git rev-parse --abbrev-ref "@{upstream}" >/dev/null 2>&1; then
  HAS_UPSTREAM=true
fi

# Extract and deduplicate trailers, filtering out known LLM/bot attributions
TRAILERS=$(git log --format='%(trailers:key=Co-authored-by,key=Signed-off-by,unfold)' \
  "$MERGE_BASE..HEAD" 2>/dev/null | sort -u | sed '/^$/d' \
  | grep -v -i -E 'noreply@anthropic\.com|noreply@openai\.com|noreply@google\.com|noreply@github\.com|users\.noreply\.github\.com' \
  || true)

# --- Output ---

echo "BASE_BRANCH=$BASE_BRANCH"
echo "MERGE_BASE=$MERGE_BASE"
echo "CURRENT_BRANCH=$CURRENT_BRANCH"
echo "COMMIT_COUNT=$COMMIT_COUNT"
echo "HAS_MERGE_COMMITS=$HAS_MERGE_COMMITS"
echo "HAS_UPSTREAM=$HAS_UPSTREAM"
echo ""
echo "=== COMMITS ==="
git log --oneline --reverse "$MERGE_BASE..HEAD"
echo ""
echo "=== COMMIT MESSAGES ==="
git log --format='--- %h ---%n%B' --reverse "$MERGE_BASE..HEAD"
echo ""
echo "=== TRAILERS ==="
if [[ -n "$TRAILERS" ]]; then
  echo "$TRAILERS"
else
  echo "(none)"
fi

if [[ "$HAS_MERGE_COMMITS" == "true" ]]; then
  echo ""
  echo "=== MERGE COMMITS WARNING ==="
  echo "The following merge commits were found in the branch history:"
  echo "$MERGE_COMMITS"
fi

# --- Dry-run exits here ---

if [[ "$DRY_RUN" == "true" ]]; then
  exit 0
fi

# --- Execute mode ---

# Create backup ref
if [[ -n "$BACKUP_REF_OVERRIDE" ]]; then
  BACKUP_REF="$BACKUP_REF_OVERRIDE"
else
  BACKUP_REF="refs/backup/squash-commits/$CURRENT_BRANCH"
fi

git update-ref "$BACKUP_REF" HEAD

echo ""
echo "=== BACKUP CREATED ==="
echo "BACKUP_REF=$BACKUP_REF"
echo "Original branch tip saved. To recover:"
echo "  git reset --hard $BACKUP_REF"
echo ""

# Soft reset to merge-base (keeps all changes staged)
git reset --soft "$MERGE_BASE"

echo "=== RESET COMPLETE ==="
echo "All changes are staged. The agent should now run git commit with the synthesized message."
