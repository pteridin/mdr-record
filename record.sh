#!/usr/bin/env bash
set -euo pipefail

DURATION_MIN="${1:-60}"
TITLE="${2:-recording}"
OUTPUT_DIR="${OUTPUT_DIR:-/recordings}"
STREAM_URL="${STREAM_URL:?STREAM_URL must be set}"
RETRY_WAIT="${RETRY_WAIT:-10}"  # seconds to wait before reconnect attempt

DURATION_SEC=$(( DURATION_MIN * 60 ))
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
SAFE_TITLE="${TITLE// /_}"

mkdir -p "$OUTPUT_DIR"

END_EPOCH=$(( $(date +%s) + DURATION_SEC ))
RUN=0

echo "Recording ${DURATION_MIN} min → ${OUTPUT_DIR}/"

while true; do
  NOW=$(date +%s)
  REMAINING=$(( END_EPOCH - NOW ))

  if [ "$REMAINING" -le 0 ]; then
    echo "Recording window elapsed."
    break
  fi

  # Each reconnect gets its own file; gaps in the stream become gaps between files.
  OUTPUT_FILE="${OUTPUT_DIR}/${SAFE_TITLE}_${TIMESTAMP}_$(printf '%03d' "$RUN").ts"
  RUN=$(( RUN + 1 ))

  echo "Starting ffmpeg — ${REMAINING}s remaining → ${OUTPUT_FILE}"

  # MPEG-TS: no finalization needed; file is valid up to any truncation point.
  ffmpeg -loglevel warning \
    -i "$STREAM_URL" \
    -t "$REMAINING" \
    -c copy \
    -y "$OUTPUT_FILE" && break  # clean exit = recording finished normally

  echo "ffmpeg exited with code $?."

  NOW=$(date +%s)
  REMAINING=$(( END_EPOCH - NOW ))

  if [ "$REMAINING" -le 0 ]; then
    echo "Recording window elapsed after disconnect."
    break
  fi

  echo "Connection lost. Retrying in ${RETRY_WAIT}s... (${REMAINING}s of recording window left)"
  sleep "$RETRY_WAIT"
done

echo "Done: ${OUTPUT_DIR}/"
