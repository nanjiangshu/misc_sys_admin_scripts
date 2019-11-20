#!/bin/bash

VERSION=3.5.0

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

pushd $tmpdir

sudo ls

wget https://github.com/singularityware/singularity/releases/download/v$VERSION/singularity-$VERSION.tar.gz
tar xvf singularity-$VERSION.tar.gz
cd singularity
./autogen.sh
./configure --prefix=/usr/local
make
sudo make install

popd

rm -rf $tmpdir
