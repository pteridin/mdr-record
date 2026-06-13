#!/usr/bin/env bash
set -euo pipefail

DURATION_MIN="${1:-60}"
TITLE="${2:-recording}"
OUTPUT_DIR="${OUTPUT_DIR:-/recordings}"
STREAM_URL="${STREAM_URL:?STREAM_URL must be set}"
CHUNK_MIN="${CHUNK_MIN:-5}"
RETRY_WAIT="${RETRY_WAIT:-10}"  # seconds to wait before reconnect attempt

DURATION_SEC=$(( DURATION_MIN * 60 ))
CHUNK_SEC=$(( CHUNK_MIN * 60 ))
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
SAFE_TITLE="${TITLE// /_}"

# Use a subdirectory per recording session so chunks stay together
SESSION_DIR="${OUTPUT_DIR}/${SAFE_TITLE}_${TIMESTAMP}"
mkdir -p "$SESSION_DIR"

END_EPOCH=$(( $(date +%s) + DURATION_SEC ))
SEGMENT_INDEX=0

echo "Recording ${DURATION_MIN} min in ${CHUNK_MIN}-min chunks → ${SESSION_DIR}/"

while true; do
  NOW=$(date +%s)
  REMAINING=$(( END_EPOCH - NOW ))

  if [ "$REMAINING" -le 0 ]; then
    echo "Recording window elapsed."
    break
  fi

  SEGMENT_PATTERN="${SESSION_DIR}/${SAFE_TITLE}_${TIMESTAMP}_%03d.ts"

  echo "Starting ffmpeg — ${REMAINING}s remaining, segment index starts at ${SEGMENT_INDEX}..."

  # -segment_start_number: continue numbering from where we left off after a reconnect
  # MPEG-TS requires no finalization; partial final chunk is still playable.
  ffmpeg -loglevel warning \
    -i "$STREAM_URL" \
    -t "$REMAINING" \
    -c copy \
    -f segment \
    -segment_time "$CHUNK_SEC" \
    -segment_format mpegts \
    -segment_start_number "$SEGMENT_INDEX" \
    -reset_timestamps 1 \
    -y "$SEGMENT_PATTERN" && break  # clean exit = recording finished normally

  EXIT_CODE=$?
  echo "ffmpeg exited with code ${EXIT_CODE}."

  # Count segments written so far to advance the index for the next run
  SEGMENT_INDEX=$(find "$SESSION_DIR" -name "*.ts" | wc -l)

  NOW=$(date +%s)
  REMAINING=$(( END_EPOCH - NOW ))

  if [ "$REMAINING" -le 0 ]; then
    echo "Recording window elapsed after disconnect."
    break
  fi

  echo "Connection lost. Retrying in ${RETRY_WAIT}s... (${REMAINING}s of recording window left)"
  sleep "$RETRY_WAIT"
done

echo "Done: ${SESSION_DIR}/"
