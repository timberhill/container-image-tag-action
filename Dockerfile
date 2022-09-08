FROM node:alpine3.15

LABEL org.opencontainers.image.source=https://github.com/timberhill/container-image-tag-action

RUN apk update && apk add git curl jq
RUN export PATH=/usr/local/bin:$PATH && npm install semver -g
COPY entrypoint.sh /entrypoint.sh

RUN adduser -u 1001 -g 1001 actionboi
USER actionboi

ENTRYPOINT ["/entrypoint.sh"]
