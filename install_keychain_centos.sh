#!/bin/bash


rundir=`dirname $0`

cd $rundir

url=http://apt.sw.be/redhat/el6/en/i386/rpmforge/RPMS/keychain-2.7.0-1.el6.rf.noarch.rpm

filename=`basename $url`
if [ ! -f "$filename" ];then
	wget $url -O $filename
fi

sudo rpm -Uvh $filename
