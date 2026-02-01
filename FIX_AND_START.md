# Fix & Start Guide

## Issues Fixed

1. ✅ Frontend Dockerfile now exposes both ports 80 and 443
2. ✅ Created automated fix script to stop Caddy and start the system

## Quick Fix (Recommended)

Run this single command:

```bash
sudo ./scripts/fix-ports-and-start.sh
```

This will:
- Stop and disable Caddy
- Verify ports are free
- Rebuild and start all containers
- Show you the status

## Manual Fix (If script doesn't work)

### Step 1: Stop Caddy
```bash
sudo systemctl stop caddy
sudo systemctl disable caddy
```

### Step 2: Verify ports are free
```bash
ss -tulpn | grep -E ":(80|443) "
```
(Should return nothing)

### Step 3: Rebuild frontend (important - we fixed the Dockerfile)
```bash
docker-compose down
docker-compose build frontend
```

### Step 4: Start all containers
```bash
docker-compose up -d
```

### Step 5: Verify everything is running
```bash
docker-compose ps
```

You should see 4 containers running:
- feedback-mongodb
- feedback-backend
- feedback-frontend (with ports 0.0.0.0:80->80/tcp and 0.0.0.0:443->443/tcp)
- feedback-backup

### Step 6: Check logs if frontend isn't running
```bash
docker-compose logs frontend
```

## After Starting Successfully

Access your feedback system:
- **From network:** https://feedback.local
- **Direct IP:** https://172.12.0.28

Browser will show security warning (self-signed cert) - click "Advanced" → "Proceed"

## Troubleshooting

### Port still in use
```bash
# Find what's using port 80
sudo lsof -i :80

# Find what's using port 443
sudo lsof -i :443

# Kill the process if needed
sudo kill -9 <PID>
```

### Frontend container won't start
```bash
# Check logs
docker-compose logs frontend

# Rebuild from scratch
docker-compose down
docker-compose build --no-cache frontend
docker-compose up -d
```

### Can't resolve backend hostname
This means the frontend container isn't on the Docker network. Fix:
```bash
docker-compose down
docker-compose up -d
```

## Verify Everything Works

```bash
./scripts/verify-network.sh
```

This checks:
- Hostname configuration
- Avahi daemon (mDNS)
- SSL certificates
- Docker containers
- Port mappings
