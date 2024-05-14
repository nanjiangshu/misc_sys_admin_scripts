#!/bin/bash

sudo apt -y install python-dev

# installing mod_wsgi
sudo apt -y install apache2-dev
sudo apt -y install httpd-wsgi 
sudo apt-get install libapache2-mod-wsgi-py3
sudo a2enmod wsgi


# for set limitation for maximum connections
tmpdir=$(mktemp -d /tmp/tmp.XXXXXXXXX) || { echo "Failed to create temp dir" >&2; exit 1; }
cd $tmpdir
wget http://dominia.org/djao/limit/mod_limitipconn-0.24.tar.bz2
tar xavf mod_limitipconn-0.24.tar.bz2
cd mod_limitipconn-0.24
sudo make install

cd 
sudo rm -rf $tmpdir


sudo systemctl restart apache2
