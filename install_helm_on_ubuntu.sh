#!/bin/bash
set -euo pipefail
# This script is used to install helm on ubuntu
tempDir=$(mktemp -d)

pushd $tempDir

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh

./get_helm.sh

popd

rm -rf $tempDir
