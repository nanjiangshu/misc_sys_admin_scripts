#!/bin/bash
set -euo pipefail

# 1. Import the Helm GPG key
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null

# 2. Install the apt-transport-https package (if not already installed)
sudo apt-get install apt-transport-https --yes

# 3. Add the Helm repository to your sources list
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

# 4. Update and install
sudo apt-get update
sudo apt-get install helm