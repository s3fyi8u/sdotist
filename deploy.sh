#!/bin/bash

# Stop script on error
set -e

echo "🚀 Starting deployment..."

# Pull latest changes
echo "📥 Pulling latest changes from git..."
git pull origin main

# Rebuild and restart containers
echo "🔄 Rebuilding and restarting Docker containers..."
docker-compose up -d --build

# Prune unused images to save space
echo "🧹 Cleaning up unused images..."
docker image prune -f

echo "✅ Deployment complete!"
