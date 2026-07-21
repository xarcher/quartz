#!/usr/bin/env bash
set -e

UPSTREAM_URL="https://github.com/jackyzha0/quartz.git"
UPSTREAM_BRANCH="v5"
ORIGIN_BRANCH="v5"
COMMIT_MSG="chore: add custom configuration for deployment"

echo "=== Quartz Upstream Sync ==="

# ── 1. Ensure upstream remote exists ──────────────────────────────────────────
if ! git remote get-url upstream &>/dev/null; then
  echo "[1/5] Adding upstream remote: $UPSTREAM_URL"
  git remote add upstream "$UPSTREAM_URL"
else
  echo "[1/5] Upstream remote already exists"
fi

# ── 2. Fetch latest upstream ───────────────────────────────────────────────────
echo "[2/5] Fetching upstream/$UPSTREAM_BRANCH..."
git fetch upstream "$UPSTREAM_BRANCH"

# ── 3. Stage all local changes ─────────────────────────────────────────────────
echo "[3/5] Staging local changes..."
git add -A

# Check if there's anything to commit or amend
if git diff --cached --quiet; then
  echo "      No new changes to stage"
else
  # If our custom commit already exists at HEAD, amend it
  # Otherwise create a new commit
  HEAD_MSG=$(git log --format="%s" -1 2>/dev/null || echo "")
  if [ "$HEAD_MSG" = "$COMMIT_MSG" ]; then
    echo "      Amending existing commit..."
    git commit --amend --no-edit
  else
    echo "      Creating new commit..."
    git commit -m "$COMMIT_MSG"
  fi
fi

# ── 4. Rebase onto upstream ────────────────────────────────────────────────────
echo "[4/5] Rebasing onto upstream/$UPSTREAM_BRANCH..."
git rebase "upstream/$UPSTREAM_BRANCH"

# ── 5. Force push to origin ────────────────────────────────────────────────────
echo "[5/5] Force pushing to origin/$ORIGIN_BRANCH..."
git push origin "$ORIGIN_BRANCH" --force-with-lease

echo ""
echo "Done! Your commit is now on top of upstream/$UPSTREAM_BRANCH."
