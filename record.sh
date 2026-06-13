#!/usr/bin/env bash
set -euo pipefail

DURATION_MIN="${1:-60}"
TITLE="${2:-recording}"
OUTPUT_DIR="${OUTPUT_DIR:-/recordings}"
STREAM_URL="${STREAM_URL:?STREAM_URL must be set}"

DURATION_SEC=$(( DURATION_MIN * 60 ))
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
OUTPUT_FILE="${OUTPUT_DIR}/${TITLE// /_}_${TIMESTAMP}.mp4"

mkdir -p "$OUTPUT_DIR"
echo "Recording ${DURATION_MIN} min → ${OUTPUT_FILE}"

ffmpeg -loglevel warning \
  -i "$STREAM_URL" \
  -t "$DURATION_SEC" \
  -c copy \
  -movflags +faststart \
  -y "$OUTPUT_FILE"

echo "Done: ${OUTPUT_FILE}"
