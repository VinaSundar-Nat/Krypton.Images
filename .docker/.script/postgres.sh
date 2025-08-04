#!/bin/bash

set -e
set -u

function create_db() {
	local database=$1
	local owner=$POSTGRES_USER'_'$database''
	local password=$POSTGRES_PASSWORD
	echo "  Creating user and database '$database'"
	psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
		CREATE USER $owner WITH PASSWORD '$password' CREATEDB;
	    CREATE DATABASE $database;
	    GRANT ALL PRIVILEGES ON DATABASE $database TO $owner;
EOSQL
}

function create_ext(){
	psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	    CREATE EXTENSION IF NOT EXISTS postgis;
		CREATE EXTENSION IF NOT EXISTS postgis_topology;
		CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
		CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
EOSQL
}

if [ -n "$POSTGRES_KR_DBS" ]; then
	echo "Creation started: $POSTGRES_KR_DBS"
	for db in $(echo $POSTGRES_KR_DBS | tr ',' '\n'); do
		create_db $db
	done
	echo "databases created"
	create_ext
fi

