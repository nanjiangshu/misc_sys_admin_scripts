#!/bin/bash
# install packages on ae.scilifelab.se
# install httpd on centos

sudo yum install html2text #needed by pconsc submit_query.cgi

sudo yum install httpd
sudo yum install mysql-server 
sudo yum install php php-mysql

sudo chkconfig httpd on
sudo chkconfig mysqld on
sudo service mysqld start

# so that web servers can be installed
sudo yum install cmake
sudo yum install html2text

sudo yum install gnuplot
# python
sudo easy_install matplotlib

bash ~/src/install_gengetopt.sh
bash ~/src/install_blast.sh
bash ~/src/install_emboss.sh #seqret which will be used by predzinc and frag1d
sudo yum install ImageMagick  # for the command convert
#sudo yum install openafs-client

sudo yum install R # install R for boctopus
# install library e1071 
# sudo R
# > install.packages("e1071")

sudo yum install python-pip
# install scipy, which will be used by boctopus
# it is a bit complicated to install scipy on centos
sudo yum python-devel
sudo yum install lapack lapack-devel blas blas-devel
sudo pip install numpy
sudo pip install numpy --upgrade
sudo pip install scipy 
sudo pip install biopython 
sudo pip install matplotlib 


#misc
sudo yum install tree
