#!/bin/bash
sudo yum -y update
sudo yum groupinstall -y 'development tools'

# sudo yum install -y zlib-devel bzip2-devel openssl-devel xz-libs wget
sudo yum install -y zlib-devel bzip2-devel openssl-devel xz-libs wget sqlite-devel

wget http://www.python.org/ftp/python/2.7.8/Python-2.7.8.tar.xz
xz -d Python-2.7.8.tar.xz
tar -xvf Python-2.7.8.tar

currdir=$PWD
cd Python-2.7.8

# Run the configure:
./configure --prefix=/usr/local

# compile and install it:
make
sudo make altinstall

cd $currdir

wget --no-check-certificate https://pypi.python.org/packages/source/s/setuptools/setuptools-1.4.2.tar.gz

# Extract the files:
tar -xvf setuptools-1.4.2.tar.gz
cd setuptools-1.4.2

# Install setuptools using the Python 2.7.8:
sudo python2.7 setup.py install

cd $currdir
curl https://raw.githubusercontent.com/pypa/pip/master/contrib/get-pip.py | sudo python2.7 -

cd $currdir
sudo pip2.7 install virtualenv

