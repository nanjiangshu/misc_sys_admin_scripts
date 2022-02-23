#!/bin/bash
# install packages on ae.scilifelab.se
# install httpd on centos
rundir=`dirname $0`
sudo apt-get update

sudo apt-get -y install gengetopt # install gengetopt , which will be used by topcons
sudo apt-get -y install xsltproc  # install xsltproc, which will be used by topcons
sudo apt-get -y install cmake     # install cmake which is need to install topcons
sudo apt-get -y install g++       # need to to install topcons
sudo apt-get -y install gnuplot    # install gnuplot
sudo apt-get -y install tcsh csh   # install csh, which will be used by psipred
sudo apt-get -y install curl       # install curl, which will be used in submit_to_servers.pl
sudo apt-get -y install sqlite3
sudo apt-get -y install libsqlite3-dev


sudo apt-get -y  install html2text #needed by pconsc submit_query.cgi

sudo apt-get -y  install imagemagick  # for the command convert

sudo apt-get -y install r-base

sudo apt-get -y  install tree

#installing perl modules
# using cpanm to install 
sudo apt-get install -y perlbrew 
perlbrew install-cpanm 
cpanm IPC::Run
cpanm Moose
cpanm Bio::Perl

# solving pip install lxml problem
sudo apt-get -y  install libxslt 
sudo apt-get -y  install libxslt-dev 
sudo apt-get -y  install libxml2
sudo apt-get -y  install libxml2-dev  
sudo apt-get -y  install libxslt1-dev 
sudo apt-get -y  install zlib1g-dev 

