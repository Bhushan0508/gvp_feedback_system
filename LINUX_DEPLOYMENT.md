# Linux Deployment Guide (Fresh Start)

Follow these steps to deploy the feedback system on a fresh Linux server.
This guide includes steps to **uninstall old Docker versions**, install a fresh copy, and configure everything to **run without pseudo** (`sudo`).

## Step 1: Clone or Update Code
On your Linux server terminal:

```bash
# Clone repo
git clone https://github.com/Bhushan0508/gvp_feedback_system.git
cd gvp_feedback_system
```

## Step 2: The "Fresh Start" Setup
We have created a master script that does everything:
1.  Uninstalls old Docker versions.
2.  Installs the latest Docker Engine.
3.  Adds your user to the `docker` group (so you don't need `sudo`).
4.  Installs mDNS (for `.local` access).
5.  Generates SSL Certificates.

**Run this command:**
```bash
chmod +x scripts/full-system-setup.sh
./scripts/full-system-setup.sh
```

## Step 3: IMPORTANT - Log Out & Log In
After the script finishes, you **MUST** log out of your ssh session (or reboot) and log back in.
This is required for the user permission changes to take effect.

```bash
exit
# Now SSH back in...
```

## Step 4: Start the System (No Sudo!)
Now you can start the system without `sudo`:

```bash
docker-compose up -d --build
```

## Step 5: Access the Application
Go to: **`https://feedback.local`** (or `https://<YOUR-SERVER-IP>`)

---
**Troubleshooting:**
-   *Permission Denied?*: Did you log out and log back in? Verify by running `groups`. You should see `docker` in the list.
-   *Site not found?*: Ensure your device is on the same Wi-Fi.
