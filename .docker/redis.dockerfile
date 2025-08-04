FROM redis:alpine
LABEL maintainer="vina"

RUN apk update && apk upgrade --no-cache

COPY   ./.docker/.config/redis.prod.conf /cache/redis.conf

ENTRYPOINT  ["redis-server", "/cache/redis.conf"]