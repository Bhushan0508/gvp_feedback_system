#!/bin/bash

# Directory to store certificates
CERT_DIR="./certs"
mkdir -p "$CERT_DIR"

# Certificate names
KEY_FILE="$CERT_DIR/server.key"
CRT_FILE="$CERT_DIR/server.crt"

# Get local network IP
LOCAL_IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1 | head -1)

echo "========================================="
echo "Generating SSL Certificates"
echo "========================================="
echo "Output: $CERT_DIR"
echo ""

# Build Subject Alternative Names
SAN="DNS:feedback.local,DNS:feedback.globalpagoda.org,DNS:localhost,IP:127.0.0.1"
if [ -n "$LOCAL_IP" ]; then
    SAN="$SAN,IP:$LOCAL_IP"
    echo "Including local IP: $LOCAL_IP"
fi
echo "Domains: feedback.local, feedback.globalpagoda.org, localhost"
echo ""

# Generate private key and certificate
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout "$KEY_FILE" \
  -out "$CRT_FILE" \
  -subj "/C=US/ST=State/L=City/O=GlobalPagoda/CN=feedback.local" \
  -addext "subjectAltName=$SAN"

echo ""
echo "✅ Certificate generation complete."
echo "   Key: $KEY_FILE"
echo "   Cert: $CRT_FILE"
echo ""
echo "Valid for:"
echo "  • https://feedback.local"
echo "  • https://feedback.globalpagoda.org"
echo "  • https://localhost"
if [ -n "$LOCAL_IP" ]; then
    echo "  • https://$LOCAL_IP"
fi
echo ""
echo "NOTE: Browsers will show a security warning for self-signed certificates."
echo "      Click 'Advanced' → 'Proceed' to continue."
echo ""
