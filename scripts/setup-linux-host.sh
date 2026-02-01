#!/bin/bash

set -e

echo "🐧 Configuring Linux Host for Local Discovery..."

# 1. Install mDNS (Avahi)
if ! command -v avahi-daemon &> /dev/null; then
    echo "📦 Installing avahi-daemon (mDNS)..."
    if [ -x "$(command -v apt-get)" ]; then
        sudo apt-get update
        sudo apt-get install -y avahi-daemon
    elif [ -x "$(command -v yum)" ]; then
        sudo yum install -y avahi
    fi
    
    # Start service
    sudo service avahi-daemon start
    echo "✅ mDNS installed. Server should be reachable as $(hostname).local"
else
    echo "✅ avahi-daemon is already installed."
fi

# 2. Check for Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed! Please install Docker first."
    exit 1
else
    echo "✅ Docker is ready."
fi

# 3. Generate Certs if missing
if [ ! -d "./certs" ] || [ ! -f "./certs/server.key" ]; then
    echo "🔐 specific certificates not found. Generating..."
    chmod +x ./scripts/generate-certs.sh
    ./scripts/generate-certs.sh
else
    echo "✅ Certificates found."
fi

echo ""
echo "🎉 Setup Complete!"
echo "To start the application, run:"
echo "  sudo docker-compose up -d --build"
echo ""
echo "Access the app at: https://feedback.local (or https://$(hostname).local)"
