FROM alpine:3.10

LABEL org.opencontainers.image.source=https://github.com/timberhill/container-image-tag-action

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
