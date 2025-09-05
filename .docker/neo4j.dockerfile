# Use the official Neo4j Community Edition image
FROM neo4j:5.25-community

LABEL maintainer="vina"

# Update & install any required tools (optional)
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

# Copy your local config into the container
COPY ./.docker/.config/neo4j.prd.conf /var/lib/neo4j/conf/neo4j.conf

# Expose Neo4j ports
# 7474 = HTTP, 7687 = Bolt
EXPOSE 7474 7687

# Neo4j official entrypoint will run automatically, no need to override
# But if you want explicit control:
ENTRYPOINT ["tini", "-g", "--", "/startup/docker-entrypoint.sh"]
CMD ["neo4j"]