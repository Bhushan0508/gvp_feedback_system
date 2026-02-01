#!/bin/bash

# Network Verification Script
# Tests if the feedback system is properly configured for local network access

echo "========================================="
echo "Network Configuration Verification"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test results
PASS=0
FAIL=0

# Function to test something
test_check() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ PASS${NC}: $2"
        ((PASS++))
    else
        echo -e "${RED}❌ FAIL${NC}: $2"
        ((FAIL++))
    fi
}

# 1. Check hostname
echo "1. Hostname Configuration"
HOSTNAME=$(hostname)
if [ "$HOSTNAME" = "feedback" ]; then
    test_check 0 "Hostname is 'feedback'"
else
    test_check 1 "Hostname should be 'feedback' but is '$HOSTNAME'"
fi
echo ""

# 2. Check Avahi daemon
echo "2. mDNS Service (Avahi)"
if systemctl is-active --quiet avahi-daemon; then
    test_check 0 "Avahi daemon is running"
else
    test_check 1 "Avahi daemon is not running"
fi
echo ""

# 3. Check network interface and IP
echo "3. Network Configuration"
LOCAL_IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1 | head -1)
if [ -n "$LOCAL_IP" ]; then
    test_check 0 "Local IP detected: $LOCAL_IP"
else
    test_check 1 "No local IP address found"
fi
echo ""

# 4. Check SSL certificates
echo "4. SSL Certificates"
if [ -f "./certs/server.crt" ] && [ -f "./certs/server.key" ]; then
    test_check 0 "Certificate files exist"

    # Check certificate validity
    if openssl x509 -in ./certs/server.crt -noout -checkend 0 >/dev/null 2>&1; then
        test_check 0 "Certificate is valid (not expired)"
    else
        test_check 1 "Certificate is expired"
    fi

    # Check if certificate includes feedback.local
    if openssl x509 -in ./certs/server.crt -noout -text | grep -q "feedback.local"; then
        test_check 0 "Certificate includes 'feedback.local' domain"
    else
        test_check 1 "Certificate missing 'feedback.local' domain"
    fi
else
    test_check 1 "Certificate files missing"
fi
echo ""

# 5. Check Docker
echo "5. Docker Configuration"
if command -v docker >/dev/null 2>&1; then
    test_check 0 "Docker is installed"

    if docker ps --filter "name=feedback-frontend" --format "{{.Status}}" | grep -q "Up"; then
        test_check 0 "Frontend container is running"
    else
        echo -e "${YELLOW}⚠️  WARN${NC}: Frontend container is not running"
        echo "         Run: docker-compose up -d"
    fi
else
    test_check 1 "Docker is not installed"
fi
echo ""

# 6. Check ports
echo "6. Port Availability"
if command -v docker >/dev/null 2>&1; then
    if docker ps --format "{{.Ports}}" | grep -q "80->80"; then
        test_check 0 "HTTP port 80 is mapped"
    else
        test_check 1 "HTTP port 80 is not mapped"
    fi

    if docker ps --format "{{.Ports}}" | grep -q "443->443"; then
        test_check 0 "HTTPS port 443 is mapped"
    else
        test_check 1 "HTTPS port 443 is not mapped"
    fi
else
    echo "Skipping port checks (Docker not running)"
fi
echo ""

# Summary
echo "========================================="
echo "Summary"
echo "========================================="
echo -e "Passed: ${GREEN}$PASS${NC}"
echo -e "Failed: ${RED}$FAIL${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed!${NC}"
    echo ""
    echo "Access your feedback system at:"
    echo "  • https://feedback.local (from any device on the network)"
    if [ -n "$LOCAL_IP" ]; then
        echo "  • https://$LOCAL_IP (direct IP access)"
    fi
    echo ""
    echo "Note: You may see a browser security warning for the self-signed certificate."
    echo "      Click 'Advanced' → 'Proceed to feedback.local' to continue."
else
    echo -e "${RED}❌ Some checks failed.${NC}"
    echo ""
    echo "Troubleshooting steps:"
    if systemctl is-active --quiet avahi-daemon; then
        :
    else
        echo "  1. Install Avahi: sudo ./scripts/setup-network.sh"
    fi
    if [ -f "./certs/server.crt" ]; then
        :
    else
        echo "  2. Generate certificates: ./scripts/generate-certs.sh"
    fi
    if docker ps --filter "name=feedback-frontend" --format "{{.Status}}" | grep -q "Up"; then
        :
    else
        echo "  3. Start Docker: docker-compose up -d"
    fi
fi
echo ""
