# Local Network Deployment Guide

This guide explains how to make the feedback system accessible on your local network at `https://feedback.local`.

## Quick Start

```bash
# 1. Verify/setup network configuration
sudo ./scripts/setup-network.sh

# 2. Generate SSL certificates
./scripts/generate-certs.sh

# 3. Start the application
docker-compose up -d

# 4. Verify everything is working
./scripts/verify-network.sh

# 5. Access from any device on your network
# Open: https://feedback.local
```

## How It Works

### mDNS (Multicast DNS)
Instead of requiring a DNS server or static IP configuration, we use **mDNS** via the Avahi daemon. This allows:

- **Zero-configuration networking**: Devices automatically discover `feedback.local`
- **Dynamic IP support**: Works even if your server's IP changes
- **Cross-platform**: Works on iPhones, Android, macOS, Windows, Linux

### HTTPS with Self-Signed Certificates
The system uses HTTPS to ensure secure connections. Since we use self-signed certificates:

- Browsers will show a security warning on first visit
- Click "Advanced" → "Proceed to feedback.local" to continue
- The connection is encrypted, but not verified by a certificate authority

## Detailed Setup

### 1. Network Configuration

The `setup-network.sh` script:
- Installs and configures Avahi daemon (mDNS)
- Sets hostname to "feedback"
- Enables the service to start on boot

```bash
sudo ./scripts/setup-network.sh
```

### 2. SSL Certificates

The `generate-certs.sh` script creates certificates valid for:
- `feedback.local` (mDNS name)
- `feedback.globalpagoda.org` (custom domain, requires router DNS)
- `localhost` (local testing)
- Your server's local IP address

```bash
./scripts/generate-certs.sh
```

Certificates are stored in `./certs/` and automatically mounted into the frontend container.

### 3. Docker Deployment

The `docker-compose.yml` is already configured with:
- Ports 80 and 443 exposed for HTTP/HTTPS
- Certificate volume mount
- Nginx configured to redirect HTTP → HTTPS

```bash
docker-compose up -d
```

### 4. Verification

Run the verification script to check all components:

```bash
./scripts/verify-network.sh
```

This checks:
- Hostname configuration
- Avahi daemon status
- Network IP detection
- SSL certificate validity
- Docker container status
- Port mappings

## Access URLs

### Recommended (mDNS)
```
https://feedback.local
```
Works on all devices on the local network without configuration.

### Alternative (Direct IP)
```
https://YOUR_SERVER_IP
```
Find your IP with: `ip -4 addr show | grep inet | grep -v 127.0.0.1`

### Custom Domain (Advanced)
```
https://feedback.globalpagoda.org
```
**Requires:** Configuring your Wi-Fi router's DNS settings to point this domain to your server's IP.

## Device Compatibility

### Works automatically:
- ✅ macOS (Safari, Chrome, Firefox)
- ✅ iOS (iPhone, iPad)
- ✅ Linux (all browsers)
- ✅ Android (Chrome, Firefox)
- ✅ Windows 10/11 (with Bonjour service or iTunes installed)

### Windows Notes:
Windows requires the Bonjour service for mDNS:
- Install iTunes (includes Bonjour), OR
- Install Bonjour Print Services from Apple
- Alternative: Use direct IP access instead

## Troubleshooting

### "This site can't be reached" error
1. Verify Avahi is running: `systemctl status avahi-daemon`
2. Check devices are on the same Wi-Fi network
3. Try direct IP access instead: `https://YOUR_IP`

### SSL Certificate Warning
This is expected with self-signed certificates:
1. Click "Advanced" or "Show Details"
2. Click "Proceed to feedback.local" or "Accept the Risk"
3. The warning only appears once per device

### Cannot access from phone
1. Ensure phone is on the same Wi-Fi network
2. Disable cellular data temporarily to force Wi-Fi
3. Try direct IP if mDNS doesn't work
4. On iOS: Settings → Wi-Fi → Your Network → Verify IP range matches server

### Port conflicts
If ports 80 or 443 are in use:
```bash
# Check what's using the ports
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :443

# Stop conflicting services
sudo systemctl stop apache2  # or nginx, or other web server
```

### Docker not starting
```bash
# Check container logs
docker-compose logs frontend

# Restart containers
docker-compose restart

# Full rebuild
docker-compose down
docker-compose up -d --build
```

## Network Architecture

```
┌─────────────────────────────────────────────┐
│  Device on Network (Phone/Laptop)          │
│                                             │
│  Browser → https://feedback.local           │
└─────────────────────┬───────────────────────┘
                      │
                      │ mDNS Query
                      │ "What's feedback.local's IP?"
                      ↓
┌─────────────────────────────────────────────┐
│  Local Wi-Fi Network                        │
│                                             │
│  mDNS Response: "feedback.local = 172.x.x.x"│
└─────────────────────┬───────────────────────┘
                      │
                      │ HTTPS Request
                      │ Port 443
                      ↓
┌─────────────────────────────────────────────┐
│  Linux Server (172.x.x.x)                   │
│                                             │
│  ┌─────────────────────────────────┐       │
│  │ Avahi Daemon                    │       │
│  │ (Broadcasts: I am feedback!)    │       │
│  └─────────────────────────────────┘       │
│                                             │
│  ┌─────────────────────────────────┐       │
│  │ Docker                          │       │
│  │                                 │       │
│  │  ┌──────────────────┐           │       │
│  │  │ Nginx (Frontend) │           │       │
│  │  │ Port 443/80      │           │       │
│  │  └────────┬─────────┘           │       │
│  │           │                     │       │
│  │  ┌────────▼─────────┐           │       │
│  │  │ Backend API      │           │       │
│  │  │ Port 3000        │           │       │
│  │  └────────┬─────────┘           │       │
│  │           │                     │       │
│  │  ┌────────▼─────────┐           │       │
│  │  │ MongoDB          │           │       │
│  │  └──────────────────┘           │       │
│  └─────────────────────────────────┘       │
└─────────────────────────────────────────────┘
```

## Security Considerations

### For Local Network Only
This setup is designed for **local network use only**. Do not expose to the internet without:
- Proper firewall configuration
- Valid SSL certificates from a trusted CA (Let's Encrypt)
- Rate limiting and DDoS protection
- Security hardening

### Current Security Features
- ✅ HTTPS encryption
- ✅ Security headers (X-Frame-Options, X-Content-Type-Options, etc.)
- ✅ Gzip compression
- ✅ MongoDB not exposed externally
- ✅ Backend only accessible via Nginx proxy

### Self-Signed Certificate Limitations
- Not verified by a Certificate Authority
- Browsers will show warnings
- Not suitable for public/production use
- Fine for local network and development

## Advanced: Custom Domain Setup

If you want to use `feedback.globalpagoda.org` instead of `feedback.local`:

### Option 1: Router DNS (Recommended)
1. Access your Wi-Fi router's admin panel (usually at 192.168.1.1)
2. Find DNS settings or "Host Names" section
3. Add entry: `feedback.globalpagoda.org → YOUR_SERVER_IP`
4. Save and restart router
5. All devices will now resolve the domain

### Option 2: Device Hosts File
On each device, edit the hosts file:

**Linux/Mac**: `/etc/hosts`
```
YOUR_SERVER_IP  feedback.globalpagoda.org
```

**Windows**: `C:\Windows\System32\drivers\etc\hosts`
```
YOUR_SERVER_IP  feedback.globalpagoda.org
```

**iOS/Android**: Not possible without jailbreak/root

## Maintenance

### Update Certificates (if IP changes)
```bash
./scripts/generate-certs.sh
docker-compose restart frontend
```

### Check System Status
```bash
./scripts/verify-network.sh
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f frontend
docker-compose logs -f backend
```

### Restart Services
```bash
# Restart all
docker-compose restart

# Restart specific service
docker-compose restart frontend
```

## Scripts Reference

### `setup-network.sh`
Configures the Linux server for network discovery:
- Installs Avahi daemon
- Sets hostname to "feedback"
- Enables mDNS broadcasting

**Usage:** `sudo ./scripts/setup-network.sh`

### `generate-certs.sh`
Creates SSL certificates for HTTPS:
- Generates self-signed certificate
- Valid for multiple domains and IP
- 10-year validity period

**Usage:** `./scripts/generate-certs.sh`

### `verify-network.sh`
Checks if everything is configured correctly:
- Hostname and Avahi status
- Certificate validity
- Docker container status
- Port mappings

**Usage:** `./scripts/verify-network.sh`

## FAQ

**Q: Why .local instead of .org?**
`.local` is the standard mDNS domain that works automatically. `.org` requires DNS configuration.

**Q: Can I use both .local and .org?**
Yes! The certificates support both. Use `.local` for automatic access, and configure `.org` if you prefer a custom domain.

**Q: Does this work outside my network?**
No. This is strictly for local network access. To access from outside, you would need port forwarding, dynamic DNS, and proper security measures.

**Q: Will this slow down my network?**
No. mDNS uses minimal bandwidth (periodic multicast announcements).

**Q: Can I change the name from 'feedback' to something else?**
Yes, but you'll need to update:
1. Hostname: `sudo hostnamectl set-hostname newname`
2. Certificates: Edit `generate-certs.sh` to use `newname.local`
3. Access URL becomes `https://newname.local`

**Q: What if my server IP changes?**
mDNS handles this automatically. The `.local` name will continue to work. You only need to regenerate certificates if you want the IP explicitly in the cert.

## Support

If you encounter issues:
1. Run `./scripts/verify-network.sh` to identify the problem
2. Check Docker logs: `docker-compose logs`
3. Verify network connectivity: `ping feedback.local`
4. Test with direct IP access first
