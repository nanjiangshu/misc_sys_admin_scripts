#!/bin/bash
# 2021-12-02

# ========== install apache 2 ===============
sudo apt -y install python
sudo apt -y install python-dev
sudo apt -y install apache2

# installing mod_wsgi
sudo apt -y install apache2-dev
sudo apt -y install libapache2-mod-wsgi-py3

# for set limitation for maximum connections
tmpdir=$(mktemp -d /tmp/tmp.XXXXXXXXX) || { echo "Failed to create temp dir" >&2; exit 1; }
trap 'rm -rf "$tmpdir"' INT TERM EXIT
pushd $tmpdir
wget http://dominia.org/djao/limit/mod_limitipconn-0.24.tar.bz2
tar xavf mod_limitipconn-0.24.tar.bz2
cd mod_limitipconn-0.24
sudo make install

popd
sudo rm -rf $tmpdir


