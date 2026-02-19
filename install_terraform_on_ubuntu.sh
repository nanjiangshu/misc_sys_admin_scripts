#!/bin/bash
set -euo pipefail

# This script is used to install terraform on ubuntu

sudo apt update
sudo apt install git unzip

# Clone the repository
git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv

# Add tfenv to your PATH so you can run it from anywhere
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc

# Reload your shell configuration
source ~/.bashrc


tfenv --version

tfenv install latest
