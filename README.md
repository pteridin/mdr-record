# stream-recorder

Dockerized stream recorder. Records an HLS stream for a configurable duration, optionally starting at a scheduled time.

## Requirements

- Docker & Docker Compose

## Setup

```bash
cp .env.example .env
# Edit .env with your values
```

## Configuration

| Variable | Description | Default |
|---|---|---|
| `STREAM_URL` | HLS stream URL to record | *(required)* |
| `START_TIME` | When to start: `HH:MM` or `YYYY-MM-DD HH:MM`. Empty = immediately. | *(empty)* |
| `DURATION_MIN` | Recording length in minutes | `60` |
| `TITLE` | Base filename (timestamp appended automatically) | `recording` |
| `RECORDINGS_DIR` | Host path where files are saved | `./recordings` |
| `TZ` | Timezone for `START_TIME` interpretation | `Europe/Berlin` |

## Usage

```bash
# Start immediately
docker compose up

# Scheduled start (picks up values from .env)
docker compose up -d
```

The container exits automatically when the recording finishes. Output files are named `<TITLE>_<YYYY-MM-DD_HH-MM>.mp4`.

## Override on the command line

```bash
START_TIME="20:00" DURATION_MIN=90 TITLE=show docker compose up
```
