#!/bin/bash

# Production deployment script for tile proxy server

set -e

echo "🚀 Deploying Bing Maps Tile Proxy Server..."

# Check if .env exists
if [ ! -f .env ]; then
    echo "⚠️  .env not found. Creating from .env.example..."
    cp .env.example .env
    echo "Please edit .env with your settings before continuing."
    exit 1
fi

# Load environment variables
export $(cat .env | grep -v '^#' | xargs)

# Build and start services
echo "📦 Building Docker images..."
docker compose build

echo "🔧 Starting services..."
docker compose up -d

# Wait for services to be healthy
echo "⏳ Waiting for services to be healthy..."
sleep 5

# Check health
if curl -f http://localhost:${EXTERNAL_PORT:-8113}/health > /dev/null 2>&1; then
    echo "✅ Deployment successful!"
    echo "🌐 Service is running at: http://localhost:${EXTERNAL_PORT:-8113}"
    echo "📊 Example tile URL: http://localhost:${EXTERNAL_PORT:-8113}/10/512/341.jpg"
else
    echo "❌ Health check failed. Checking logs..."
    docker compose logs --tail=50
    exit 1
fi

echo ""
echo "📝 Useful commands:"
echo "  View logs:       docker compose logs -f"
echo "  Stop services:   docker compose down"
echo "  Restart:         docker compose restart"
echo "  Scale workers:   docker compose up -d --scale tile-server=4"