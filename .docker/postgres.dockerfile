FROM postgis/postgis:17-3.4

LABEL maintainer="vina"
LABEL description="PostgreSQL 17 with PostGIS"

ENV POSTGRES_DB=master
ENV POSTGRES_USER=postgres

COPY ./.docker/.script/postgres.sh /docker-entrypoint-initdb.d/01-init-postgis.sh