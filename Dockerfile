FROM ghcr.io/timberhill/container-image-tag-base:0.1.0

LABEL org.opencontainers.image.source=https://github.com/timberhill/container-image-tag-action

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
