# Dockerfile
FROM mongo:latest

LABEL maintainer="vina"

# Copy custom MongoDB configuration
COPY ./.docker/.config/mongo.prd.conf /etc/mongod.conf

# Expose MongoDB port
EXPOSE 27017

# Use the official MongoDB entrypoint
CMD ["mongod", "--config", "/etc/mongod.conf"]