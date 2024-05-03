#!/bin/bash

#Note: singularity has been renamed to apptainer and 3.8.7 is the last version of singularity

source ./utils.sh

VERSION=3.8.7

usage="
USAGE: $0 <version>

Default version is $VERSION

Created 2017-10-27, updated 2024-05-03, Nanjiang Shu
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

currdir=$PWD
cd $tmpdir

isInstallGo=false
go_version=$(go version | awk '{print $3}' |  sed 's/go//');
if [ "$go_version" != "" ];then
    cmp=$(compare_version "$go_version" "1.13")
    if [ "$cmp" == "less" ]; then
        echo "The installed golang version is less than 1.13. Please install golang version 1.13 or higher"
        isInstallGo=true
    fi
else
    echo "golang is not installed. Please install golang version 1.13 or higher"
    isInstallGo=true
fi

if [ "$isInstallGo" == "true" ]; then
    # install golang (at least version 1.13)
    bash ./install_go_on_linux.sh 1.22.2
fi

export GOPATH=${HOME}/go
export PATH=/usr/local/go/bin:${PATH}:${GOPATH}/bin
wget https://github.com/singularityware/singularity/releases/download/v$VERSION/singularity-$VERSION.tar.gz
tar xvf singularity-$VERSION.tar.gz
cd singularity-$VERSION
./mconfig
cd builddir
make
sudo make install

cd $currdir

rm -rf $tmpdir
