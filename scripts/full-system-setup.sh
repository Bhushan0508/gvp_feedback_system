#!/bin/bash

# full-system-setup.sh
# 1. Uninstalls old Docker
# 2. Reinstalls latest Docker
# 3. Configures non-sudo user access
# 4. Sets up mDNS and Certs

set -e

echo "⚠️  WARNING: This script will remove existing Docker installations and reinstall them."
read -p "Press [Enter] to continue or Ctrl+C to cancel..."

echo ""
echo "🚀 [1/5] Removing old Docker versions..."
# Uninstall conflicting packages
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do 
    sudo apt-get remove -y $pkg || true
done

echo ""
echo "📥 [2/5] Installing Docker Engine (Official Script)..."
# Use the official convenience script
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

echo ""
echo "👤 [3/5] Configuring Non-Sudo Access..."
# Create docker group if it doesn't exist
sudo groupadd docker || true
# Add current user to group
sudo usermod -aG docker $USER
echo "✅ User '$USER' added to docker group."

echo ""
echo "🌐 [4/5] Setting up Network Discovery (mDNS)..."
# Install Avahi for .local support
if [ -x "$(command -v apt-get)" ]; then
    sudo apt-get update
    sudo apt-get install -y avahi-daemon
    sudo service avahi-daemon start
elif [ -x "$(command -v yum)" ]; then
    sudo yum install -y avahi
fi

echo ""
echo "🔐 [5/5] Generating Certificates..."
# Ensure script is executable
chmod +x ./scripts/generate-certs.sh
./scripts/generate-certs.sh

echo ""
echo "🎉 SETUP COMPLETE!"
echo "-----------------------------------------------------"
echo "IMPORTANT: You must LOG OUT and LOG BACK IN for the"
echo "           user permissions to take effect."
echo "-----------------------------------------------------"
echo "After logging back in, you can run:"
echo "   docker-compose up -d --build"
echo "   (No 'sudo' needed!)"
