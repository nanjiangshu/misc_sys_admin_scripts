#!/bin/bash

rundir=`dirname $0`
cd $rundir

urlbase=http://dl.fedoraproject.org/pub/epel/6/x86_64/

#1.
filename=epel-release-6-8.noarch.rpm
url=$urlbase/$filename
if [ ! -f $filename ];then
    wget $url -O $filename 
fi

sudo rpm -Uvh $filename

#2

filename=gengetopt-2.22.5-3.el6.x86_64.rpm
url=$urlbase/$filename
#wget $url -O index.html
#html2text index.html > index.txt
wget $url -O $filename
sudo yum install $filename

