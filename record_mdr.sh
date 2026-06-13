#!/usr/bin/env bash
# Dependency: brew install ffmpeg

set -euo pipefail

DURATION_MIN="${1:-60}"
TITLE="${2:-mdr_recording}"
OUTPUT_DIR="$HOME/Movies/MDR"
STREAM_URL="https://mdr-live.ard-mcdn.de/mdr/sa/hls/de/master1080p5000.m3u8"

DURATION_SEC=$(( DURATION_MIN * 60 ))
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
OUTPUT_FILE="${OUTPUT_DIR}/${TITLE// /_}_${TIMESTAMP}.mp4"

if ! command -v ffmpeg &>/dev/null; then
  echo "ERROR: install ffmpeg with: brew install ffmpeg"; exit 1
fi

mkdir -p "$OUTPUT_DIR"
echo "Recording ${DURATION_MIN} min → ${OUTPUT_FILE}"

ffmpeg -loglevel warning \
  -i "$STREAM_URL" \
  -t "$DURATION_SEC" \
  -c copy \
  -movflags +faststart \
  -y "$OUTPUT_FILE"

echo "Done: ${OUTPUT_FILE}"
