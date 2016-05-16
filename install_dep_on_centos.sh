#!/bin/bash
# install packages on ae.scilifelab.se
# install httpd on centos
rundir=`dirname $0`

sudo yum -y  install html2text #needed by pconsc submit_query.cgi

sudo yum -y  install httpd
sudo yum -y  install mysql-server 
sudo yum -y  install php php-mysql

sudo chkconfig httpd on
sudo chkconfig mysqld on
sudo service mysqld start

# so that web servers can be installed
sudo yum -y  install cmake
sudo yum -y  install html2text

sudo yum -y  install gnuplot
# python
sudo easy_install matplotlib

bash $rundir/install_gengetopt.sh
bash $rundir/install_blast.sh
bash $rundir/install_emboss.sh #seqret which will be used by predzinc and frag1d
bash $rundir/install_keychain_centos.sh
sudo bash $rundir/install_openafs_centos.sh

sudo yum -y  install ImageMagick  # for the command convert
#sudo yum -y  install openafs-client

sudo yum -y  install R # install R for boctopus
# install library e1071 
# sudo R
# > install.packages("e1071")

sudo yum -y  install python-pip
# install scipy, which will be used by boctopus
# it is a bit complicated to install scipy on centos
sudo yum -y  install python-devel
sudo yum -y  install lapack lapack-devel blas blas-devel
sudo pip install numpy
sudo pip install numpy --upgrade
sudo pip install scipy 
sudo pip install biopython 
sudo pip install matplotlib 

sudo yum -y  install glibc.i686 #for running 32 bit applications


#misc
sudo yum -y  install tree

# fixing basename and sort 
$rundir/fix_app_location_relinking.sh # this fixed the figure for TOPCONS

sudo $rundir/install_python2.7_centos.sh

sudo $rundir/install_dep_django_centos.sh

#installing perl modules
sudo yum -y  install perl-Moose
# better to install with the shell
# sudo perl -MCPAN -e shell
# cpan > install Moose
# cpan > install JFIELDS/BioPerl-1.6.924.tar.gz
# cpan > install IPC::Run
#sudo perl -MCPAN -e 'install JFIELDS/BioPerl-1.6.924.tar.gz'
#sudo perl -MCPAN -e 'install IPC::Run'
#sudo perl -MCPAN -e 'install Moose'


sudo yum -y  install python-devel
sudo yum -y  install libxslt-devel libxml2-devel
sudo yum -y install html2text

sudo /usr/bin/pip install --upgrade --force-reinstall  lxml
sudo /usr/bin/pip install --upgrade --force-reinstall  mod_wsgi
