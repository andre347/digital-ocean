#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Variables
DOMAIN="your_domain"  # Replace with your domain
EMAIL="your_email@example.com"  # Replace with your email for Certbot

# Update package list and install prerequisites
echo "Updating package list..."
sudo apt update

# Install Docker
echo "Installing Docker..."
sudo apt install -y docker.io

# Verify Docker Compose is available
echo "Checking Docker Compose version..."
docker compose version

# Navigate to the project directory (assuming the script is run from the project directory)
echo "Navigating to the project directory..."
cd "$(dirname "$0")"

# Create a Docker network if it doesn't exist
if ! docker network ls | grep -q web-network; then
    echo "Creating Docker network..."
    docker network create web-network
fi

# Build and run the Docker containers
echo "Building and starting Docker containers..."
docker compose up --build -d

# Allow HTTP traffic through the firewall
echo "Configuring firewall to allow HTTP traffic..."
sudo ufw allow 80/tcp

# Get the public IP address of the server
IP_ADDRESS=$(curl -s http://checkip.amazonaws.com)

# Output the IP address for the user
echo "Deployment completed. Your application should be accessible at http://$DOMAIN or http://$IP_ADDRESS"
