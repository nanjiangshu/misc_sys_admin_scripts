#!/bin/bash -x

# Install below pre-requisites:
sudo yum -y install gcc openssl-devel bzip2-devel

# Download python
tmpdir=$(mktemp -d /tmp/tmpdir.install_python3.6_centos.XXXXXXXXX) || { echo "Failed to create temp dir" >&2; exit 1; } 


trap 'rm -rf "$tmpdir"' INT TERM EXIT

cd $tmpdir
wget https://www.python.org/ftp/python/3.7.6/Python-3.7.6.tgz


tar xzf Python-3.7.6.tgz
cd Python-3.7.6
./configure --enable-optimizations
sudo make altinstall

sudo ln -sfn /usr/local/bin/python3.7 /usr/bin/python3.7

sudo ln -sfn /usr/bin/python3.7 /usr/bin/python3

rm -rf $tmpdir
