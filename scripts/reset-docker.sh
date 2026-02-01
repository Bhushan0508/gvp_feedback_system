#!/bin/bash

echo "Element: 🗑️  Cleaning up existing Docker resources..."

# 1. Stop and remove containers, networks, volumes, and images created by up
# -v: Remove named volumes declared in the `volumes` section of the Compose file and anonymous volumes attached to containers.
# --rmi all: Remove all images used by any service.
# --remove-orphans: Remove containers for services not defined in the Compose file.
sudo docker-compose down -v --rmi all --remove-orphans

echo "Element: 🧹  Pruning unused Docker objects (optional safety clean)..."
# This removes dangling images, stopped containers, etc., to ensure a clean state.
# We don't use -a (all) to avoid deleting images from other projects unless explicitly desired.
sudo docker container prune -f
sudo docker network prune -f

echo "Element: ✨  Cleanup complete. You are ready to run ./setup-linux-host.sh"
