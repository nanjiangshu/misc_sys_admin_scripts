#!/bin/bash

# install R-shiny server on ubuntu 12.04-14.10


# first add 
#    deb http://ftp.acc.umu.se/mirror/CRAN/bin/linux/ubuntu trusty/
# to the file /etc/apt/sources.list

echo  "deb http://ftp.acc.umu.se/mirror/CRAN/bin/linux/ubuntu trusty/" | sudo tee -a /etc/apt/sources.list

# add pubkey
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 51716619E084DAB9
sudo apt-get update
sudo apt-get upgrade -y


sudo apt-get -y install r-base

# installing X11 for the rgl R package
sudo apt-get -y install xorg openbox
sudo apt-get install libx11-dev 
sudo apt-get -y install libglu1-mesa-dev 

# install shiny R packages
sudo su - -c "R -e \"install.packages('shiny', repos='https://cran.rstudio.com/')\""
sudo su - -c "R -e \"install.packages(c('rmarkdown','igraph','plotrix'), repos='http://ftp.acc.umu.se/mirror/CRAN/')\""
sudo su - -c "R -e \"install.packages(c('rgl','rglwidget'), repos='http://ftp.acc.umu.se/mirror/CRAN/')\""
sudo su - -c "R -e \"install.packages(c('zoo'), repos='http://ftp.acc.umu.se/mirror/CRAN/')\""


# install gdebi and then using gdebi to install the R-shiny server
sudo apt-get -y install gdebi-core
mkdir -p ~/tmp
cd ~/tmp
wget https://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-1.4.1.759-amd64.deb
sudo gdebi -n shiny-server-1.4.1.759-amd64.deb


# configuration file can be find at /etc/shiny-server/shiny-server.conf
# the default site is at /srv/shiny-server
# the URL is 

# http://IP:3838/

