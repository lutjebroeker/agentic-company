#!/bin/bash
set -euo pipefail

# Exit silently if Telegram credentials are not configured
if [[ -z "${TELEGRAM_BOT_TOKEN:-}" || -z "${TELEGRAM_CHAT_ID:-}" ]]; then
  exit 0
fi

# Get message from argument or stdin
MESSAGE="${1:-}"
if [[ -z "$MESSAGE" ]]; then
  MESSAGE=$(cat 2>/dev/null || true)
fi

# Exit if no message
if [[ -z "$MESSAGE" ]]; then
  exit 0
fi

# Only trigger for significant output — skip noise
MATCHERS=("error" "fail" "complete" "deploy" "commit" "push" "merge" "release" "warning")
SIGNIFICANT=false
MESSAGE_LOWER=$(echo "$MESSAGE" | tr '[:upper:]' '[:lower:]')

for pattern in "${MATCHERS[@]}"; do
  if [[ "$MESSAGE_LOWER" == *"$pattern"* ]]; then
    SIGNIFICANT=true
    break
  fi
done

if [[ "$SIGNIFICANT" != "true" ]]; then
  exit 0
fi

# Send via Telegram Bot API
API_URL="https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage"

curl -s -X POST "$API_URL" \
  -d chat_id="$TELEGRAM_CHAT_ID" \
  -d text="$MESSAGE" \
  -d parse_mode="Markdown" \
  > /dev/null 2>&1 || true

exit 0
