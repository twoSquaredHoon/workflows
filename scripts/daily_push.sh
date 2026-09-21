#!/usr/bin/env bash
# Daily commit + push safety net for the GitHub contribution graph.
# Idempotent: safe to run manually, from cron, or from launchd — running it
# more than once on the same KST day (or while offline) just no-ops or retries.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

LOG_FILE="log/daily.md"
DATE="$(TZ=Asia/Seoul date +%Y-%m-%d)"

log() { printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')" "$1"; }

GIT_CHECK_ERR="$(git rev-parse --is-inside-work-tree 2>&1 1>/dev/null)"
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  log "Not a git repo: $REPO_DIR -- HOME=$HOME PATH=$PATH USER=$(whoami 2>&1) -- git said: ${GIT_CHECK_ERR:-<no stderr>}"
  exit 1
fi

if git pull --ff-only origin main >/dev/null 2>&1; then
  log "Pulled latest from origin/main."
else
  log "Could not pull (offline or auth issue) — continuing with local state."
fi

if grep -qE "^${DATE}( |\$)" "$LOG_FILE" 2>/dev/null; then
  log "Already logged ${DATE} locally."
else
  printf '%s | auto\n' "$DATE" >> "$LOG_FILE"
  git add "$LOG_FILE"
  git commit -m "chore: daily log ${DATE}" >/dev/null
  log "Committed log entry for ${DATE}."
fi

AHEAD="$(git rev-list --count origin/main..HEAD 2>/dev/null || echo 0)"
if [ "${AHEAD}" -gt 0 ]; then
  if git push origin main >/dev/null 2>&1; then
    log "Pushed ${AHEAD} commit(s) to origin/main."
  else
    log "Push failed (offline or auth issue) — ${AHEAD} commit(s) pending, will retry next run."
  fi
else
  log "Nothing to push."
fi
