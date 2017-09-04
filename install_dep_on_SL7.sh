#!/bin/bash
# install dependance on Scientific Linux 7

rundir=`dirname $0`

sudo yum -y  install html2text #needed by pconsc submit_query.cgi

sudo yum -y  install httpd
sudo yum -y  install mysql-server 
sudo yum -y  install php php-mysql

sudo chkconfig httpd on
sudo chkconfig mysqld on
sudo service mysqld start


sudo yum install -y gcc sqlite-devel libxml2 libxml2-devel libxslt libxslt-devel python-devel

# so that web servers can be installed
sudo yum -y  install cmake
sudo yum -y  install gnuplot

bash $rundir/install_gengetopt.sh
bash $rundir/install_blast.sh
bash $rundir/install_emboss.sh #seqret which will be used by predzinc and frag1d
bash $rundir/install_keychain_centos.sh
sudo bash $rundir/install_openafs_centos.sh

sudo yum -y  install ImageMagick  # for the command convert
#sudo yum -y  install openafs-client

sudo yum -y  install R # install R for boctopus
sudo R -e "install.packages(c('ggplot2', 'reshape'), repos='http://ftp.acc.umu.se/mirror/CRAN/')"  # for subcons
sudo R -e "install.packages(c('e1071'), repos='http://ftp.acc.umu.se/mirror/CRAN/')" # for boctopus

# install scipy, which will be used by boctopus
# it is a bit complicated to install scipy on centos
sudo yum -y  install lapack lapack-devel blas blas-devel
sudo yum -y  install glibc.i686 #for running 32 bit applications


# fixing basename and sort 
$rundir/fix_app_location_relinking.sh # this fixed the figure for TOPCONS
sudo $rundir/install_dep_django_centos.sh

#installing perl modules
# for cpanm to easy install of perl modules
sudo yum install perl-App-cpanminus.noarch 
sudo cpanm Moose
sudo cpanm IPC::Run
sudo cpanm Bio::Perl
sudo cpanm CGI


sudo /usr/bin/pip install --upgrade --force-reinstall  lxml
sudo /usr/bin/pip install --upgrade --force-reinstall  mod_wsgi

#misc
sudo yum -y  install tree
sudo yum -y  install tmux
