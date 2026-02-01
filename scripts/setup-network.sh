#!/bin/bash

# Local Network Setup Script
# This script configures mDNS (Avahi) for automatic network discovery

set -e

echo "========================================="
echo "Local Network Setup for Feedback System"
echo "========================================="
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "⚠️  This script needs sudo privileges to install packages and configure the system."
   echo "Please run with: sudo ./scripts/setup-network.sh"
   exit 1
fi

# Step 1: Install Avahi daemon (mDNS)
echo "Step 1: Installing Avahi daemon for mDNS broadcasting..."
apt-get update -qq
apt-get install -y avahi-daemon avahi-utils libnss-mdns

# Step 2: Configure hostname
echo ""
echo "Step 2: Verifying hostname configuration..."
CURRENT_HOSTNAME=$(hostname)
if [ "$CURRENT_HOSTNAME" != "feedback" ]; then
    echo "Setting hostname to 'feedback'..."
    hostnamectl set-hostname feedback
    echo "feedback" > /etc/hostname
    echo "✅ Hostname set to 'feedback'"
else
    echo "✅ Hostname already set to 'feedback'"
fi

# Step 3: Enable and start Avahi daemon
echo ""
echo "Step 3: Enabling and starting Avahi daemon..."
systemctl enable avahi-daemon
systemctl restart avahi-daemon

# Verify service is running
if systemctl is-active --quiet avahi-daemon; then
    echo "✅ Avahi daemon is running"
else
    echo "❌ Failed to start Avahi daemon"
    exit 1
fi

# Step 4: Get local IP address
echo ""
echo "Step 4: Network Information..."
LOCAL_IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1 | head -1)
echo "Local IP Address: $LOCAL_IP"

# Step 5: Summary
echo ""
echo "========================================="
echo "✅ Local Network Setup Complete!"
echo "========================================="
echo ""
echo "Your server is now broadcasting as 'feedback.local' on the network."
echo ""
echo "Access URLs:"
echo "  • https://feedback.local (mDNS - works automatically)"
echo "  • https://$LOCAL_IP (Direct IP access)"
echo "  • https://feedback.globalpagoda.org (requires DNS configuration on router)"
echo ""
echo "Next steps:"
echo "  1. Run: ./scripts/generate-certs.sh (regenerate certificates with IP)"
echo "  2. Run: docker-compose up -d (start the application)"
echo "  3. Test from another device on the same network"
echo ""
echo "Note: Browsers will show a security warning for self-signed certificates."
echo "      Click 'Advanced' → 'Proceed to feedback.local' to continue."
echo ""
