#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Variables
BRANCH="main"  # Replace with the branch you want to pull from

# Pull the latest changes from the Git repository
echo "Pulling the latest changes from the $BRANCH branch..."
git fetch origin
git reset --hard origin/$BRANCH

# Rebuild and restart Docker containers
echo "Rebuilding and restarting Docker containers..."
sudo docker-compose build
sudo docker-compose up -d

# Verify the deployment
echo "Verifying the deployment..."
sudo docker-compose ps

# Output a success message
echo "Upgrade complete. Your application is now running the latest version."
