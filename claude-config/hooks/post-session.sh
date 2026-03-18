#!/bin/bash
set -euo pipefail

# Recursion guard
if [[ "${post_session_active:-}" == "true" ]]; then
  exit 0
fi
export post_session_active=true

# Read stdin (hook input) but we don't need it
cat > /dev/null 2>&1 || true

# Find the agentic-company repo root
REPO_DIR=""
CANDIDATES=(
  "$HOME/projects/agentic-company"
  "/root/projects/agentic-company"
  "$HOME/agentic-company"
)

for dir in "${CANDIDATES[@]}"; do
  if [[ -d "$dir/learning" ]]; then
    REPO_DIR="$dir"
    break
  fi
done

# Fallback: try git to find it
if [[ -z "$REPO_DIR" ]]; then
  REPO_DIR=$(git -C "$HOME/projects/agentic-company" rev-parse --show-toplevel 2>/dev/null || true)
fi

if [[ -z "$REPO_DIR" || ! -d "$REPO_DIR/learning" ]]; then
  exit 0
fi

CHANGELOG="$REPO_DIR/learning/changelog.md"

# Create changelog if it doesn't exist
if [[ ! -f "$CHANGELOG" ]]; then
  echo "# Changelog" > "$CHANGELOG"
  echo "" >> "$CHANGELOG"
fi

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "- ${TIMESTAMP} — session ended — auto-logged by post-session hook" >> "$CHANGELOG"

exit 0
