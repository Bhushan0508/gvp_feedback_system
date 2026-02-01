#!/bin/bash

# Directory to store certificates
CERT_DIR="./certs"
mkdir -p "$CERT_DIR"

# Certificate names
KEY_FILE="$CERT_DIR/server.key"
CRT_FILE="$CERT_DIR/server.crt"

echo "Generating Self-Signed SSL Certificates in $CERT_DIR..."

# Generate private key and certificate
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout "$KEY_FILE" \
  -out "$CRT_FILE" \
  -subj "/C=US/ST=State/L=City/O=GlobalPagoda/CN=feedback.local" \
  -addext "subjectAltName=DNS:feedback.local,DNS:feedback.globalpagoda.org,DNS:localhost,IP:127.0.0.1"

echo "✅ Certificate generation complete."
echo "   Key: $KEY_FILE"
echo "   Cert: $CRT_FILE"
echo ""
echo "NOTE: On the first visit, your browser will warn about the self-signed certificate."
echo "      You must manually trust it or click 'Advanced -> Proceed'."
