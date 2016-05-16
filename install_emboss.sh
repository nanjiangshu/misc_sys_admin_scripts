#!/bin/bash

rundir=`dirname $0`

tmpdir=$(mktemp -d /tmp/tmp.XXXXXXXXX) || { echo "Failed to create temp dir" >&2; exit 1; }
cd $tmpdir

url=ftp://emboss.open-bio.org/pub/EMBOSS/EMBOSS-6.6.0.tar.gz

filename=EMBOSS-6.6.0.tar.gz
if [ ! -f $filename ];then
    wget $url -O  $filename
fi

tar -xvzf $filename


cd EMBOSS-6.6.0
make clean

./configure --without-x # --prefix=
make 
sudo make install 

cd /
sudo rm -rf $tmpdir
