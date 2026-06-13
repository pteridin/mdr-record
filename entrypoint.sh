#!/usr/bin/env bash
set -euo pipefail

# START_TIME: time to begin recording, e.g. "14:30" (today) or "2024-12-01 14:30"
# DURATION_MIN: how many minutes to record
# TITLE: base name for the output file

START_TIME="${START_TIME:-}"
DURATION_MIN="${DURATION_MIN:-60}"
TITLE="${TITLE:-recording}"
TZ="${TZ:-Europe/Berlin}"

export TZ

if [ -z "$START_TIME" ]; then
  echo "No START_TIME set — starting recording immediately."
  exec /app/record.sh "$DURATION_MIN" "$TITLE"
fi

# Parse START_TIME: if it looks like HH:MM, treat it as today's date in local time
if [[ "$START_TIME" =~ ^[0-9]{2}:[0-9]{2}$ ]]; then
  TARGET_EPOCH=$(date -d "$(date +%Y-%m-%d) $START_TIME" +%s)
else
  TARGET_EPOCH=$(date -d "$START_TIME" +%s)
fi

NOW_EPOCH=$(date +%s)
WAIT_SEC=$(( TARGET_EPOCH - NOW_EPOCH ))

if [ "$WAIT_SEC" -le 0 ]; then
  echo "START_TIME '$START_TIME' is in the past — starting immediately."
else
  echo "Waiting ${WAIT_SEC}s until $START_TIME (TZ=$TZ)..."
  sleep "$WAIT_SEC"
fi

exec /app/record.sh "$DURATION_MIN" "$TITLE"
