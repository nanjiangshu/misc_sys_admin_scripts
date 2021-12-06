#!/bin/bash

VERSION=3.5.3

usage="
USAGE: $0 <version>

Default version is $VERSION

Created 2017-10-27, updated 2017-10-27, Nanjiang Shu
"

if [ "$1" != "" ];then
    VERSION=$1
fi
tmpdir=$(mktemp -d /tmp/tmpdir.install_singularity_on_linux.XXXXXXXXX) || { echo "Failed to create temp dir" >&2; exit 1; }

trap 'rm -rf "$tmpdir"' INT TERM EXIT


sudo ls

# install dependencies
sudo apt-get update && \
    sudo apt-get install -y build-essential \
    libssl-dev uuid-dev libseccomp-dev \
    pkg-config squashfs-tools cryptsetup \
    make gcc

# install golang (at least version 1.13)

export GO_VERSION=1.13.3 OS=linux ARCH=amd64  # change this as you need
wget -O /tmp/go${GO_VERSION}.${OS}-${ARCH}.tar.gz https://dl.google.com/go/go${GO_VERSION}.${OS}-${ARCH}.tar.gz && \
      sudo tar -C /usr/local -xzf /tmp/go${GO_VERSION}.${OS}-${ARCH}.tar.gz

echo 'export GOPATH=${HOME}/go' >> ~/.bashrc
echo 'export PATH=/usr/local/go/bin:${PATH}:${GOPATH}/bin' >> ~/.bashrc

#. ~/.bashrc
export GOPATH=${HOME}/go
export PATH=/usr/local/go/bin:${PATH}:${GOPATH}/bin

currdir=$PWD
cd $tmpdir
wget https://github.com/singularityware/singularity/releases/download/v$VERSION/singularity-$VERSION.tar.gz
tar xvf singularity-$VERSION.tar.gz
cd singularity
./mconfig
cd builddir
make
sudo make install

cd $currdir

rm -rf $tmpdir
