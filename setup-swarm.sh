#!/bin/bash

# Initial setup script for Docker Swarm on Hetzner VM
# Run this script once on your Hetzner VM to initialize Docker Swarm

set -e

echo "🔧 Setting up Docker Swarm on Hetzner VM..."

# Update system
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "🐳 Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo "✅ Docker installed"
else
    echo "ℹ️  Docker already installed"
fi

# Install Docker Compose if not present
if ! command -v docker-compose &> /dev/null; then
    echo "🐳 Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose installed"
else
    echo "ℹ️  Docker Compose already installed"
fi

# Initialize Docker Swarm if not already done
if ! docker info --format '{{.Swarm.LocalNodeState}}' | grep -q active; then
    echo "🐛 Initializing Docker Swarm..."
    docker swarm init --advertise-addr $(curl -s ifconfig.me)
    echo "✅ Docker Swarm initialized"
else
    echo "ℹ️  Docker Swarm already initialized"
fi

# Create deployment directory
sudo mkdir -p /opt/english-subtitels
sudo chown $USER:$USER /opt/english-subtitels

# Install curl if not present (for health checks)
if ! command -v curl &> /dev/null; then
    echo "📡 Installing curl..."
    sudo apt install -y curl
fi

echo "✅ Docker Swarm setup completed!"
echo "🔑 Make sure to configure GitHub secrets with your SSH key for deployment"
