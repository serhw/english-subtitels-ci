#!/bin/bash

# Docker Swarm deployment script for Hetzner VM
# This script should be run on the Docker Swarm manager node

set -e

echo "🚀 Starting deployment to Docker Swarm..."

# Configuration
STACK_NAME="english-subtitels"
COMPOSE_FILE="docker-compose.production.yml"
NGINX_CONFIG="nginx.conf"

# Create Docker configs if they don't exist
echo "📝 Creating Docker configs..."
if ! docker config inspect nginx_config >/dev/null 2>&1; then
    docker config create nginx_config $NGINX_CONFIG
    echo "✅ nginx_config created"
else
    echo "ℹ️  nginx_config already exists"
fi

# Deploy the stack
echo "🐳 Deploying Docker stack..."
docker stack deploy -c $COMPOSE_FILE --with-registry-auth $STACK_NAME

# Wait for deployment
echo "⏳ Waiting for services to be ready..."
sleep 30

# Check service status
echo "📊 Service status:"
docker stack services $STACK_NAME

echo "✅ Deployment completed!"
echo "🌐 Your service should be available at: http://128.140.2.122"
