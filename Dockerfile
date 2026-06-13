FROM alpine:3.19

RUN apk add --no-cache ffmpeg bash tzdata

WORKDIR /app

COPY record.sh /app/record.sh
COPY entrypoint.sh /app/entrypoint.sh

RUN chmod +x /app/record.sh /app/entrypoint.sh

ENV TZ=Europe/Berlin

VOLUME ["/recordings"]

ENTRYPOINT ["/app/entrypoint.sh"]
