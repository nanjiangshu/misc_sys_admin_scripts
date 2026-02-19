#!/bin/bash
# this script is used to install vault on ubuntu
set -euo pipefail

# Update and install dependencies
sudo apt-get update && sudo apt-get install -y gpg wget curl coreutils && \

# Add HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \

# Add official HashiCorp repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list && \

# Update and install Vault
sudo apt-get update && sudo apt-get install -y vault && \

# Verify installation
vault --version