#!/usr/bin/env bash
# bash
set -euo pipefail

# Usage:
#   ./scripts/squash-range.sh "2025-12-11 18:03" "2025-12-13 11:28" [remote] [branch]
START="${1:-}"
END="${2:-}"
REMOTE="${3:-fenix}"
BRANCH="${4:-develop}"

if [ -z "$START" ] || [ -z "$END" ]; then
  echo "Usage: $0 \"<since>\" \"<before>\" [remote] [branch]" >&2
  exit 2
fi

# require git
command -v git >/dev/null || { echo "git not found" >&2; exit 2; }

# ensure clean worktree
if ! git diff --quiet || ! git diff --staged --quiet; then
  echo "Espace de travail non propre. Stashpez ou commitez d'abord." >&2
  exit 3
fi

git fetch --all
git checkout "$BRANCH"

# get commits in range (oldest -> newest)
commits_range=$(git rev-list --reverse --since="$START" --before="$END" "$BRANCH" || true)
if [ -z "$commits_range" ]; then
  echo "Aucun commit trouvé entre \"$START\" et \"$END\" sur $BRANCH." >&2
  exit 0
fi

first=$(echo "$commits_range" | head -n1)
last=$(echo "$commits_range" | tail -n1)

# base = parent of first, or root if none
base=$(git rev-parse "${first}^" 2>/dev/null || true)
tmp_branch="tmp-squash-$$"

if [ -z "$base" ]; then
  root=$(git rev-list --max-parents=0 HEAD)
  git checkout -b "$tmp_branch" "$root"
else
  git checkout -b "$tmp_branch" "$base"
fi

# apply range without committing
for c in $commits_range; do
  git cherry-pick --no-commit "$c" || { echo "Conflit sur $c — résolvez manuellement." >&2; exit 4; }
done

git commit -m "Squash: $START → $END"

# reapply tail commits (commits after last up to branch tip)
tail_commits=$(git rev-list --reverse "${last}".."$BRANCH" || true)
# remove the first element if it equals last (since range included last)
# git rev-list "last..branch" starts after last, so above is fine.
if [ -n "$tail_commits" ]; then
  for c in $tail_commits; do
    git cherry-pick "$c" || { echo "Conflit en réappliquant $c — résolvez." >&2; exit 5; }
  done
fi

# update branch and push
git checkout "$BRANCH"
git reset --hard "$tmp_branch"
git push "$REMOTE" "$BRANCH" --force-with-lease

# cleanup
git branch -D "$tmp_branch"

echo "Opération terminée : commits de \"$START\" à \"$END\" squashés et poussés vers $REMOTE/$BRANCH."
