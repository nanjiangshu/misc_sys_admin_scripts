#!/bin/bash

# Set the location and file name of the Miniconda installer script
MINICONDA_INSTALLER="https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh"
  
# Set the installation directory
MINICONDA_DIR="$HOME/miniconda3"

# Create a temporary directory and move into it
TMPDIR=$(mktemp -d)
cd $TMPDIR

# Ensures that when the script exits, the temporary directory is deleted
trap 'rm -rf "$TMPDIR"' EXIT

pushd .

# Download the Miniconda installer script
wget "$MINICONDA_INSTALLER" -O miniconda.sh

# Install Miniconda
bash miniconda.sh -b -p "$MINICONDA_DIR"

# Add Miniconda to PATH
echo "## Add paths for miniconda3" >> ~/.bashrc
echo "export PATH=\"$MINICONDA_DIR/bin:\$PATH\"" >> ~/.bashrc

source ~/.bashrc

conda update -n base -y conda

popd

echo "Miniconda installed successfully"