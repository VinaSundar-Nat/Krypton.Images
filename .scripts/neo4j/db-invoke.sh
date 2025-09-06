#!/bin/bash
set -e
set -u
source ./db-vars.sh

if [ -n "$NEO4J_DB" ]; then
    echo "Creation started: $NEO4J_DB"
    DB_CN=$(docker ps -a -q --filter "name=$CONTAINER_NAME-*")
    echo "Container id for DB: $DB_CN"
    
    if [ -z "$DB_CN" ]; then
        echo "Error: No container found with name pattern $CONTAINER_NAME-*"
        exit 1
    fi
    
    # Check if container is running
    CONTAINER_STATUS=$(docker inspect --format='{{.State.Status}}' "$DB_CN")
    if [ "$CONTAINER_STATUS" != "running" ]; then
        echo "Error: Container $DB_CN is not running (status: $CONTAINER_STATUS)"
        exit 1
    fi

    echo "Executing db-admin.sh in container $DB_CN..."

    # Method 1: Copy script to container and execute
    # Copy the script and dependencies to the container
    docker cp ./db-admin.sh "$DB_CN":/tmp/db-admin.sh
    docker cp ./db-vars.sh "$DB_CN":/tmp/db-vars.sh
    
    # Make script executable and run it
    docker exec "$DB_CN" chmod +x /tmp/db-admin.sh
    docker exec "$DB_CN" bash -c "cd /tmp && ./db-admin.sh"
    
    # Clean up (optional)
    docker exec "$DB_CN" rm -f /tmp/db-admin.sh /tmp/db-vars.sh
    
    echo "Database creation completed successfully!"
    
else
    echo "NEO4J_DB is not set or empty"
    exit 1
fi