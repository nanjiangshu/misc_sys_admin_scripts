#!/bin/bash

# Exit on error
set -e

echo "Starting Minikube installation on Ubuntu 22.04..."

# Update system packages
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install dependencies
echo "Installing dependencies..."
sudo apt install -y curl apt-transport-https conntrack

# Install kubectl if not already installed
if ! command -v kubectl &> /dev/null; then
  echo "Installing kubectl..."
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
else
  echo "kubectl is already installed."
fi

# Install Docker if not already installed
if ! command -v docker &> /dev/null; then
  echo "Installing Docker..."
  sudo apt install -y docker.io
  sudo usermod -aG docker $USER
  echo "Docker installed. Please log out and log back in for group changes to take effect."
else
  echo "Docker is already installed."
fi

# Download Minikube binary
echo "Downloading Minikube..."
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# Install Minikube
echo "Installing Minikube..."
chmod +x minikube-linux-amd64
sudo mv minikube-linux-amd64 /usr/local/bin/minikube

# Verify Minikube installation
echo "Verifying Minikube installation..."
minikube version

# Start Minikube with Docker driver
echo "Starting Minikube with Docker driver..."
minikube start --driver=docker

# Check Minikube status
echo "Checking Minikube status..."
minikube status

echo "Minikube installation completed successfully!"

