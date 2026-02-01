# Linux Deployment Guide

Follow these steps to deploy the feedback system on your Linux server (e.g., Ubuntu/Debian).

## Prerequisites
- Linux Server connected to the local network.
- `git` installed.

## Step 1: Clone or Update Code
On your Linux server terminal:

```bash
# If cloning for the first time
git clone https://github.com/Bhushan0508/gvp_feedback_system.git
cd gvp_feedback_system

# If already cloned
git pull origin main
```

## Step 2: Run Auto-Setup
We have created a script that installs dependencies (like mDNS) and generates SSL certificates.

```bash
chmod +x scripts/setup-linux-host.sh
./scripts/setup-linux-host.sh
```

**What this does:**
1.  Installs `avahi-daemon` so your server is discoverable as `feedback.local`.
2.  Generates self-signed SSL certificates in `./certs`.
3.  Checks that Docker is ready.

## Step 3: Start the System
Run the application with Docker Compose.

```bash
sudo docker-compose up -d --build
```

## Step 4: Access the Application
On any device (Phone, Laptop) connected to the **same Wi-Fi/Network**:

1.  Open Chrome/Safari.
2.  Go to: **`https://feedback.local`**
3.  **Security Warning**: You will see a "Not Secure" warning because we created our own certificate.
    -   **Chrome**: Click "Advanced" -> "Proceed to feedback.local (unsafe)".
    -   **Safari**: Click "Show Details" -> "visit this website".

## Troubleshooting

-   **"Site can't be reached" at `feedback.local`**:
    -   Try accessing via IP address: `https://<YOUR-SERVER-IP>`.
    -   If IP works but `.local` doesn't, allow UDP port 5353 on your firewall: `sudo ufw allow 5353/udp`.

-   **"Connection Refused"**:
    -   Check if docker is running: `sudo docker ps`.
    -   Ensure ports 80 and 443 are not used by another app (like Apache).
