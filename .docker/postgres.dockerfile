FROM postgres:17.5 AS base

LABEL maintainer="vina"
LABEL description="PostgreSQL 17.5 with PostGIS 3.5.3 extension"

# Database configuration
ARG DB="master"
ENV POSTGRES_DB=master
ENV POSTGRES_USER=postgres

# PostGIS configuration
ENV POSTGIS_MAJOR=3

# Add PostgreSQL APT repository for latest packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
    && curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/postgresql-archive-keyring.gpg] http://apt.postgresql.org/pub/repos/apt/ bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Update package lists and install PostGIS
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        # ca-certificates: for accessing remote raster files
        # fix: https://github.com/postgis/docker-postgis/issues/307
        ca-certificates \
        # PostGIS packages (without version pinning to get latest available)
        postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
        postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts \
        # Additional useful packages
        postgresql-contrib \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean


# Copy initialization script
COPY ./.docker/.script/postgres.sh /docker-entrypoint-initdb.d/01-init-postgis.sh
RUN chmod +x /docker-entrypoint-initdb.d/01-init-postgis.sh

# Expose PostgreSQL port
EXPOSE 5432

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD pg_isready -U $POSTGRES_USER -d $POSTGRES_DB

# Set default command
CMD ["postgres"]