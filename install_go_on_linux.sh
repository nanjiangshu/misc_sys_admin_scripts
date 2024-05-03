#!/bin/bash

VERSION=1.22.2

usage="
USAGE: $0 <version>

Default version is $VERSION

Created 2023-01-20, updated 2024-05-03, Nanjiang Shu
"

if [ "$1" != "" ];then
    VERSION=$1
fi
tmpdir=$(mktemp -d /tmp/tmpdir.install_go_on_linux.XXXXXXXXX) || { echo "Failed to create temp dir" >&2; exit 1; }


trap 'rm -rf "$tmpdir"' INT TERM EXIT

sudo ls > /dev/null

# install dependencies
sudo apt-get update && \
    sudo apt-get install -y build-essential \
    libssl-dev uuid-dev libseccomp-dev \
    pkg-config squashfs-tools cryptsetup \
    make gcc

currdir=$PWD
pushd $tmpdir

# install golang
export GO_VERSION=$VERSION OS=linux ARCH=amd64  # change this as you need
wget -O go${GO_VERSION}.${OS}-${ARCH}.tar.gz https://dl.google.com/go/go${GO_VERSION}.${OS}-${ARCH}.tar.gz
tar -xvzf go${GO_VERSION}.${OS}-${ARCH}.tar.gz

if [ -d /usr/local/go ] ;then
    sudo rm -rf /usr/local/go
fi
sudo rsync -arv go/ /usr/local/go/

echo 'export GOPATH=${HOME}/go' >> ~/.bashrc
echo 'export PATH=/usr/local/go/bin:${PATH}:${GOPATH}/bin' >> ~/.bashrc

#. ~/.bashrc
export GOPATH=${HOME}/go
export PATH=/usr/local/go/bin:${PATH}:${GOPATH}/bin


popd

rm -rf $tmpdir
