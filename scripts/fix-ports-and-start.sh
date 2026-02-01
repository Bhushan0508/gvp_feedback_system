#!/bin/bash

# Fix Port Conflicts and Start Feedback System
# This script stops Caddy and starts the feedback system

set -e

echo "========================================="
echo "Fixing Port Conflicts & Starting System"
echo "========================================="
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "⚠️  This script needs sudo privileges to stop Caddy."
   echo "Please run with: sudo ./scripts/fix-ports-and-start.sh"
   exit 1
fi

# Step 1: Stop Caddy
echo "Step 1: Stopping Caddy server..."
if systemctl is-active --quiet caddy; then
    systemctl stop caddy
    systemctl disable caddy
    echo "✅ Caddy stopped and disabled"
else
    echo "✅ Caddy is not running"
fi

# Step 2: Verify ports are free
echo ""
echo "Step 2: Verifying ports 80 and 443 are free..."
if netstat -tulpn 2>/dev/null | grep -q ":80 " || ss -tulpn | grep -q ":80 "; then
    echo "❌ Port 80 is still in use"
    echo "Checking what's using it:"
    lsof -i :80 2>/dev/null || ss -tulpn | grep :80
    exit 1
fi

if netstat -tulpn 2>/dev/null | grep -q ":443 " || ss -tulpn | grep -q ":443 "; then
    echo "❌ Port 443 is still in use"
    echo "Checking what's using it:"
    lsof -i :443 2>/dev/null || ss -tulpn | grep :443
    exit 1
fi

echo "✅ Ports 80 and 443 are free"

# Step 3: Start Docker Compose as the feedback user
echo ""
echo "Step 3: Starting Docker containers..."
cd /home/feedback/gvp_feedback_system
sudo -u feedback docker-compose down 2>/dev/null || true
sudo -u feedback docker-compose up -d

echo ""
echo "Step 4: Waiting for containers to start..."
sleep 10

# Step 5: Check status
echo ""
echo "Step 5: Checking container status..."
sudo -u feedback docker-compose ps

echo ""
echo "========================================="
echo "✅ Setup Complete!"
echo "========================================="
echo ""
echo "Your feedback system should now be accessible at:"
echo "  • https://feedback.local"
echo "  • https://172.12.0.28"
echo ""
echo "Run this to verify: ./scripts/verify-network.sh"
echo ""
