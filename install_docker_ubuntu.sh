#!/bin/bash
set -euo pipefail

# This script is used to install docker and docker compose CLI on ubuntu

curl -fsSL https://get.docker.com/ | sh

sudo usermod -aG docker $USER

# install docker compose CLI
defaultVersion="v5.0.2"
version=""
latestVersion=$(curl -v  https://github.com/docker/compose/releases/latest 2>&1 | grep location | awk -F"/" '{print $NF}')
if [ "$latestVersion" = "" ]; then
  version=$defaultVersion
else
  version=$latestVersion
fi

mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/$version/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose && chmod +x ~/.docker/cli-plugins/docker-compose
