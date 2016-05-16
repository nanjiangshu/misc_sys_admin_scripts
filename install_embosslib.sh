#!/bin/bash

rundir=`dirname $0`

cd $rundir

url=ftp://ftp.pbone.net/mirror/ftp5.gwdg.de/pub/opensuse/repositories/home:/joscott/CentOS_CentOS-6/x86_64/EMBOSS-libs-6.4.0-20.1.x86_64.rpm

filename=EMBOSS-libs-6.4.0-20.1.x86_64.rpm
wget $url -O  $filename

sudo rpm -Uvh $filename
