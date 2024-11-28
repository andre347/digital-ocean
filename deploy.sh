#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Variables
DOMAIN="your_domain"  # Replace with your domain
EMAIL="your_email@example.com"  # Replace with your email for Certbot

# Update package list and upgrade existing packages
echo "Updating package list and upgrading packages..."
sudo apt update && sudo apt upgrade -y

# Install Docker
echo "Installing Docker..."
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" -y
sudo apt update
sudo apt install docker-ce -y

# Install Docker Compose
echo "Installing Docker Compose..."
sudo rm -f /usr/local/bin/docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Ensure Docker Compose is executable and in path
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Verify Docker Compose installation
docker-compose --version
if [ $? -ne 0 ]; then
  echo "Docker Compose installation failed. Exiting."
  exit 1
fi

# Ensure Docker starts on boot and start Docker service
sudo systemctl enable docker
sudo systemctl start docker

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
docker-compose up --build -d

# Allow HTTP traffic through the firewall
echo "Configuring firewall to allow HTTP traffic..."
sudo ufw allow 80/tcp

# Get the public IP address of the server
IP_ADDRESS=$(curl -s http://checkip.amazonaws.com)

# Output the IP address for the user
echo "Deployment completed. Your application should be accessible at http://$DOMAIN or http://$IP_ADDRESS"

# Note: The user needs to log out and back in for the Docker group changes to take effect
echo "Please log out and back in for Docker group changes to take effect."
