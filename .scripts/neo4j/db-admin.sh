#!/bin/bash
set -e
set -u
source ./db-vars.sh

# Check if arrays are defined and have the same length
if [ ${#NEO4J_USER[@]} -ne ${#NEO4J_PASSWORD[@]} ]; then
    echo "Error: Arrays NEO4J_USER, NEO4J_PASSWORD, and NEO4J_DB must have the same length"
    exit 1
fi

for i in "${!NEO4J_USER[@]}"; do
    user="${NEO4J_USER[$i]}"
    pass="${NEO4J_PASSWORD[$i]}"
    db=$NEO4J_DB

    echo "Processing: User: $user, Password: [HIDDEN], DB: $db"

    /var/lib/neo4j/bin/cypher-shell -u $ADMIN_USER -p $ADMIN_PASSWORD -d system \
    "CREATE USER ${user} IF NOT EXISTS 
    SET PLAINTEXT PASSWORD '${pass}' 
    SET HOME DATABASE ${db} 
    SET STATUS ACTIVE 
    SET PASSWORD CHANGE NOT REQUIRED;"

    if [  $? -eq 0 ]; then
        echo "${user} User created ."
    else
        exit 1
    fi
                
    echo "---"
done
