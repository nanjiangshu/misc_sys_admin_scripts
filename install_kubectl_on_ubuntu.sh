#!/bin/bash
set -euo pipefail
# This script is used to install kubectl on ubuntu

# Download the latest release
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Install the binary
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl