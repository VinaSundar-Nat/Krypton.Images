#!/bin/bash
set -e
set -u
source ./db-vars.sh

if [ -n "$POSTGRES_DB" ]; then
    echo "Creation started: $POSTGRES_DB"
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
    
    echo "Executing db-create.sh in container $DB_CN..."
    
    # Method 1: Copy script to container and execute
    # Copy the script and dependencies to the container
    docker cp ./db-create.sh "$DB_CN":/tmp/db-create.sh
    docker cp ./db-vars.sh "$DB_CN":/tmp/db-vars.sh
    
    # Make script executable and run it
    docker exec "$DB_CN" chmod +x /tmp/db-create.sh
    docker exec "$DB_CN" bash -c "cd /tmp && ./db-create.sh"
    
    # Clean up (optional)
    docker exec "$DB_CN" rm -f /tmp/db-create.sh /tmp/db-vars.sh
    
    # Alternative Method 2: Execute script content directly (uncomment to use)
    # docker exec -i "$DB_CN" bash < ./db-create.sh
    
    # Alternative Method 3: If scripts are in a mounted volume (uncomment to use)
    # docker exec "$DB_CN" bash -c "cd /path/to/scripts && ./db-create.sh"
    
    echo "Database creation completed successfully!"
    
else
    echo "POSTGRES_DB is not set or empty"
    exit 1
fi