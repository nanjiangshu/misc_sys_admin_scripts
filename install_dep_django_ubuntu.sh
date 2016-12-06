#!/bin/bash
#started 2015-02-10

sudo apt-get -y install apache2

# installing mod_wsgi
sudo apt-get -y install apache2-dev
sudo apt-get -y install httpd-wsgi 


# for set limitation for maximum connections
tmpdir=$(mktemp -d /tmp/tmp.XXXXXXXXX) || { echo "Failed to create temp dir" >&2; exit 1; }
cd $tmpdir
wget http://dominia.org/djao/limit/mod_limitipconn-0.24.tar.bz2
tar xavf mod_limitipconn-0.24.tar.bz2
cd mod_limitipconn-0.24
sudo make install

cd 
sudo rm -rf $tmpdir


