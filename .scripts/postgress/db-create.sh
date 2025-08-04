#!/bin/bash
set -e
set -u
source ./db-vars.sh

# Function to create database and user
function create_db() {
    local database=$1
    local owner=$2
    local password=$3
    
    echo "Creating user and database '$database'"
    
    # Use the admin credentials to create user and database
    PGPASSWORD='$ccat0.Nest' psql -h localhost -U Dbadmin -d master -v ON_ERROR_STOP=1 <<-EOSQL
        CREATE USER $owner WITH PASSWORD '$password' CREATEDB;
        CREATE DATABASE $database;
        GRANT ALL PRIVILEGES ON DATABASE $database TO $owner;
EOSQL
}

# Function to create PostGIS extensions
function create_ext() {
    local user=$1
    local database=$2
    local password=$3
    
    echo "Creating PostGIS extensions in database '$database' for user '$user'"
    
    # Connect as the database owner to create extensions
    PGPASSWORD="$password" psql -h localhost -U "$user" -d "$database" -v ON_ERROR_STOP=1 <<-EOSQL
        CREATE EXTENSION IF NOT EXISTS postgis;
        CREATE EXTENSION IF NOT EXISTS postgis_topology;
        CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
        CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
EOSQL
}

# Function to iterate through arrays and create databases
function initiate_create_dbs() {
    # Check if arrays are defined and have the same length
    if [ ${#POSTGRES_USER[@]} -ne ${#POSTGRES_PASSWORD[@]} ] || 
       [ ${#POSTGRES_USER[@]} -ne ${#POSTGRES_DB[@]} ]; then
        echo "Error: Arrays POSTGRES_USER, POSTGRES_PASSWORD, and POSTGRES_DB must have the same length"
        exit 1
    fi
    
    for i in "${!POSTGRES_USER[@]}"; do
        user="${POSTGRES_USER[$i]}"
        pass="${POSTGRES_PASSWORD[$i]}"
        db="${POSTGRES_DB[$i]}"
        
        echo "Processing: User: $user, Password: [HIDDEN], DB: $db"
        
        # Create database and user
        if create_db "$db" "$user" "$pass"; then
            echo "Successfully created database '$db' and user '$user'"
        else
            echo "Failed to create database '$db' and user '$user'"
            continue
        fi
        
        # Create extensions
        if create_ext "$user" "$db" "$pass"; then
            echo "Successfully created extensions in database '$db'"
        else
            echo "Failed to create extensions in database '$db'"
        fi
        
        echo "---"
    done
}

# Main execution
echo "Starting database creation process..."
initiate_create_dbs
echo "Database creation process completed."