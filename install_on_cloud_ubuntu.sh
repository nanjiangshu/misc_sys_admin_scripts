#!/bin/bash

sudo apt-get update
sudo apt-get install blast2    # install blastgpg, which will be used by topcons
sudo apt-get install gengetopt # install gengetopt , which will be used by topcons
sudo apt-get install xsltproc  # install xsltproc, which will be used by topcons
sudo apt-get install cmake     # install cmake which is need to install topcons
sudo apt-get install g++       # need to to install topcons
sudo apt-get install apache2    # install apache
sudo apt-get install php5       # install php5
sudo apt-get install gnuplot    # install gnuplot
sudo apt-get install tcsh csh   # install csh, which will be used by psipred
sudo apt-get install curl       # install curl, which will be used in submit_to_servers.pl
sudo apt-get install git        # install github
sudo apt-get install ia32-libs  # install ia32-libs so that 32-bit programs can be run as well
sudo apt-get install openafs-client # install openafs
sudo apt-get install heimdal-clients-x  # install kinit klist 

