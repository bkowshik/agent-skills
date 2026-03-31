#!/usr/bin/env bash
set -euo pipefail

# fetch-comments.sh — Helper script for the review-pr-comments skill.
# Handles preflight checks, fetching PR review threads via GraphQL,
# and posting inline replies via the REST API.
# The agent handles classification, code changes, and user interaction.

usage() {
  cat <<'EOF'
Usage: fetch-comments.sh [OPTIONS]

Modes:
  --fetch                Fetch all active (unresolved, non-outdated) review
                         threads from the PR and output as JSON
  --reply                Post a reply to a review comment thread
                         (requires --comment-id and --body)

Options:
  --pr <number|url>      PR number or URL (default: auto-detect from current branch)
  --comment-id <id>      Database ID of the root comment to reply to (--reply mode)
  --body <text>          Reply body text in Markdown (--reply mode)
  -h, --help             Show this help message

In --fetch mode, outputs a JSON array of active review threads to stdout.
In --reply mode, posts a reply and outputs the API response.
EOF
}

# --- Argument parsing ---

MODE=""
PR_INPUT=""
COMMENT_ID=""
REPLY_BODY=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --fetch)
      MODE="fetch"
      shift
      ;;
    --reply)
      MODE="reply"
      shift
      ;;
    --pr)
      PR_INPUT="$2"
      shift 2
      ;;
    --comment-id)
      COMMENT_ID="$2"
      shift 2
      ;;
    --body)
      REPLY_BODY="$2"
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

if [[ -z "$MODE" ]]; then
  echo "ERROR: Must specify --fetch or --reply mode." >&2
  usage >&2
  exit 1
fi

# --- Preflight checks ---

# Check we're in a git repo
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "ERROR: Not a git repository." >&2
  exit 1
fi

# Check gh CLI is installed
if ! command -v gh >/dev/null 2>&1; then
  echo "ERROR: GitHub CLI (gh) is not installed." >&2
  echo "Install it from https://cli.github.com/ and run 'gh auth login'." >&2
  exit 1
fi

# Check gh is authenticated
if ! gh auth status >/dev/null 2>&1; then
  echo "ERROR: GitHub CLI is not authenticated." >&2
  echo "Run 'gh auth login' to authenticate." >&2
  exit 1
fi

# --- PR detection ---

# Detect repo owner/name from the git remote
REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner' 2>/dev/null) || {
  echo "ERROR: Could not detect GitHub repository. Ensure this repo has a GitHub remote." >&2
  exit 1
}

OWNER="${REPO%%/*}"
REPO_NAME="${REPO##*/}"

if [[ -n "$PR_INPUT" ]]; then
  # Extract PR number from URL or use directly
  if [[ "$PR_INPUT" =~ /pull/([0-9]+) ]]; then
    PR_NUMBER="${BASH_REMATCH[1]}"
  elif [[ "$PR_INPUT" =~ ^[0-9]+$ ]]; then
    PR_NUMBER="$PR_INPUT"
  else
    echo "ERROR: Invalid PR reference: $PR_INPUT" >&2
    echo "Provide a PR number (e.g., 42) or URL (e.g., https://github.com/owner/repo/pull/42)." >&2
    exit 1
  fi
else
  # Auto-detect PR from current branch
  PR_NUMBER=$(gh pr view --json number -q '.number' 2>/dev/null) || {
    echo "ERROR: No open PR found for the current branch." >&2
    echo "Specify a PR number with --pr <number> or switch to a branch with an open PR." >&2
    exit 1
  }
fi

# Verify if the current user has permission to update the PR (includes push access to the head branch)
PR_CAN_UPDATE=$(gh pr view "$PR_NUMBER" --json viewerCanUpdate -q '.viewerCanUpdate' 2>/dev/null) || true
if [[ "$PR_CAN_UPDATE" == "false" ]]; then
  echo "ERROR: You do not have permission to update PR #$PR_NUMBER." >&2
  echo "You need write access to the head branch to push changes." >&2
  exit 1
fi

# --- Fetch mode ---

if [[ "$MODE" == "fetch" ]]; then
  # GraphQL query to fetch review threads with pagination.
  # The reviewThreads query inherently returns only inline review comments —
  # top-level issue comments are excluded by design (satisfies FR-001 scope).
  QUERY='
  query($owner: String!, $name: String!, $pr: Int!, $endCursor: String) {
    repository(owner: $owner, name: $name) {
      pullRequest(number: $pr) {
        reviewThreads(first: 100, after: $endCursor) {
          pageInfo {
            hasNextPage
            endCursor
          }
          nodes {
            id
            isResolved
            isOutdated
            comments(first: 100) {
              nodes {
                databaseId
                body
                author {
                  login
                }
                path
                line
              }
            }
          }
        }
      }
    }
  }
  '

  # Fetch all pages and combine, then filter to active threads
  RAW_THREADS=$(gh api graphql --paginate \
    -F owner="$OWNER" \
    -F name="$REPO_NAME" \
    -F pr="$PR_NUMBER" \
    -f query="$QUERY" 2>/dev/null) || {
    echo "ERROR: Failed to fetch review threads from GitHub API." >&2
    exit 1
  }

  # Parse and filter: keep only threads where isResolved=false and isOutdated=false
  # Output a JSON array of active threads with relevant fields
  echo "$RAW_THREADS" | jq -s '
    [
      .[]
      | .data.repository.pullRequest.reviewThreads.nodes[]
      | select(.isResolved == false and .isOutdated == false)
      | {
          threadId: .id,
          rootCommentId: .comments.nodes[0].databaseId,
          path: .comments.nodes[0].path,
          line: .comments.nodes[0].line,
          author: .comments.nodes[0].author.login,
          body: .comments.nodes[0].body,
          replyCount: ((.comments.nodes | length) - 1)
        }
    ]
  '

  exit 0
fi

# --- Reply mode ---

if [[ "$MODE" == "reply" ]]; then
  if [[ -z "$COMMENT_ID" ]]; then
    echo "ERROR: --comment-id is required in --reply mode." >&2
    exit 1
  fi
  if [[ -z "$REPLY_BODY" ]]; then
    echo "ERROR: --body is required in --reply mode." >&2
    exit 1
  fi

  # Post reply via REST API
  gh api \
    "repos/$OWNER/$REPO_NAME/pulls/$PR_NUMBER/comments/$COMMENT_ID/replies" \
    -f body="$REPLY_BODY" || {
    echo "ERROR: Failed to post reply to comment $COMMENT_ID." >&2
    exit 1
  }

  exit 0
fi
