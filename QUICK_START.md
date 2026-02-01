# Quick Start - Local Network Access

Your feedback system is configured for automatic local network discovery via mDNS.

## Access URL

```
https://feedback.local
```

Access this URL from any device on your local network (phones, tablets, laptops).

## Initial Setup (Already Done ✅)

Your system is already configured:
- ✅ Hostname set to 'feedback'
- ✅ Avahi daemon (mDNS) running
- ✅ SSL certificates generated
- ✅ Nginx configured for HTTPS
- ✅ Docker compose ready

## Starting the Application

```bash
# Start all services
docker-compose up -d

# Verify everything is running
./scripts/verify-network.sh

# View logs if needed
docker-compose logs -f
```

## Stopping the Application

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (careful - deletes data!)
docker-compose down -v
```

## First-Time Browser Access

When you first visit `https://feedback.local`:

1. Browser will show a security warning (self-signed certificate)
2. Click "Advanced" or "Show Details"
3. Click "Proceed to feedback.local" or "Accept the Risk"
4. The warning only appears once per device

## Accessing from Different Devices

### iPhone/iPad
1. Connect to the same Wi-Fi network
2. Open Safari
3. Go to: `https://feedback.local`
4. Accept certificate warning

### Android
1. Connect to the same Wi-Fi network
2. Open Chrome
3. Go to: `https://feedback.local`
4. Accept certificate warning

### Laptop/Desktop (Mac/Linux)
1. Connect to the same Wi-Fi network
2. Open any browser
3. Go to: `https://feedback.local`
4. Accept certificate warning

### Windows
1. Ensure Bonjour service is installed (comes with iTunes)
2. Or use direct IP: `https://172.12.0.28`
3. Accept certificate warning

## Alternative Access (Direct IP)

If mDNS doesn't work:
```
https://172.12.0.28
```

Find current IP with:
```bash
ip -4 addr show | grep inet | grep -v 127.0.0.1
```

## Troubleshooting

### Can't connect from phone
- Ensure phone is on the same Wi-Fi network
- Try disabling cellular data temporarily
- Try direct IP access instead

### "Site can't be reached"
- Check services: `docker-compose ps`
- Restart services: `docker-compose restart`
- Check firewall: `sudo ufw status`

### Port conflicts
```bash
# Check what's using ports
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :443

# Stop conflicting service
sudo systemctl stop apache2  # or nginx
```

## Maintenance Commands

```bash
# Check status
./scripts/verify-network.sh

# View logs
docker-compose logs -f

# Restart a service
docker-compose restart frontend
docker-compose restart backend

# Rebuild after code changes
docker-compose up -d --build
```

## Network Information

- **Server IP:** 172.12.0.28
- **mDNS Name:** feedback.local
- **HTTP Port:** 80 (redirects to HTTPS)
- **HTTPS Port:** 443

## For More Details

See `LOCAL_NETWORK_GUIDE.md` for comprehensive documentation.
