#!/bin/bash

rundir=`dirname $0`

cd $rundir

url=ftp://emboss.open-bio.org/pub/EMBOSS/EMBOSS-6.6.0.tar.gz

filename=EMBOSS-6.6.0.tar.gz
if [ ! -f $filename ];then
    wget $url -O  $filename
fi

tar -xvzf $filename


cd EMBOSS-6.6.0

export PATH=/usr/local/bin:/usr/bin:/bin; ./configure --disable-shared
make "LDFLAGS=-Wl,-static"
#sudo make install 
