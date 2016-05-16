#!/bin/bash

# install legacy blast
rundir=`dirname $0`

tmpdir=$(mktemp -d /tmp/tmp.XXXXXXXXX) || { echo "Failed to create temp dir" >&2; exit 1; }
cd $tmpdir

url=ftp://ftp.ncbi.nlm.nih.gov/blast/executables/release/LATEST/blast-2.2.26-x64-linux.tar.gz
#url=ftp://ftp.ncbi.nlm.nih.gov/blast/executables/LATEST/ncbi-blast-2.2.29+-x64-linux.tar.gz

filename=blast-2.2.26-x64-linux.tar.gz

if [ ! -f $filename ];then
    wget $url -O $filename
fi

tar -xvzf $filename

sudo rsync -auvz blast-2.2.26/bin/ /usr/bin/

cd /
sudo rm -rf $tmpdir
