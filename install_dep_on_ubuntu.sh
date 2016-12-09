#!/bin/bash
# install packages on ae.scilifelab.se
# install httpd on centos
rundir=`dirname $0`
sudo apt-get update

sudo apt-get -y install gengetopt # install gengetopt , which will be used by topcons
sudo apt-get -y install xsltproc  # install xsltproc, which will be used by topcons
sudo apt-get -y install cmake     # install cmake which is need to install topcons
sudo apt-get -y install g++       # need to to install topcons
sudo apt-get -y install apache2    # install apache
sudo apt-get -y install php5       # install php5
sudo apt-get -y install gnuplot    # install gnuplot
sudo apt-get -y install tcsh csh   # install csh, which will be used by psipred
sudo apt-get -y install curl       # install curl, which will be used in submit_to_servers.pl
sudo apt-get -y install git        # install github
sudo apt-get -y install ia32-libs  # install ia32-libs so that 32-bit programs can be run as well
sudo apt-get -y install emboss
sudo apt-get -y install hmmer
sudo apt-get -y install blast2    # install blastgpg, which will be used by topcons
sudo apt-get -y install sqlite3
sudo apt-get -y install libsqlite3-dev


sudo apt-get -y  install html2text #needed by pconsc submit_query.cgi

sudo apt-get -y  install mysql-server 
sudo apt-get -y  install php5 php-mysql

sudo /etc/init.d/mysql start 

# so that web servers can be installed
sudo apt-get -y  install cmake

sudo apt-get -y  install gnuplot
# python
sudo easy_install matplotlib


sudo apt-get -y  install imagemagick  # for the command convert

sudo apt-get -y install r-base

sudo su - -c "R -e \"install.packages(c('e1071','zoo'), repos='http://ftp.acc.umu.se/mirror/CRAN/')\""


sudo apt-get -y  install python-pip
# install scipy, which will be used by boctopus
# it is a bit complicated to install scipy on centos
sudo apt-get -y  install python-dev
sudo apt-get -y  install liblapack liblapack-dev libblas libblas-dev
sudo pip install virtualenv
sudo pip install numpy
sudo pip install numpy --upgrade
sudo pip install scipy 
sudo pip install biopython 
sudo pip install matplotlib 


#misc
sudo apt-get -y  install tree

sudo $rundir/install_dep_django_ubuntu.sh

#installing perl modules
sudo apt-get -y  install libmoose-perl 
# better to install with the shell
# sudo perl -MCPAN -e shell
# cpan > install Moose
# cpan > install JFIELDS/BioPerl-1.6.924.tar.gz
# cpan > install IPC::Run
#sudo perl -MCPAN -e 'install JFIELDS/BioPerl-1.6.924.tar.gz'
#sudo perl -MCPAN -e 'install IPC::Run'
#sudo perl -MCPAN -e 'install Moose'
export PERL_MM_USE_DEFAULT=1
export PERL_EXTUTILS_AUTOINSTALL="--defaultdeps"
sudo perl -MCPAN -e 'install IPC::Run' 
sudo perl -MCPAN -e 'install Moose'
sudo perl -MCPAN -e 'install JFIELDS/BioPerl-1.6.924.tar.gz'

# solving pip install lxml problem
sudo apt-get -y  install libxslt 
sudo apt-get -y  install libxslt-dev 
sudo apt-get -y  install libxml2
sudo apt-get -y  install libxml2-dev  
sudo apt-get -y  install libxslt1-dev 
sudo apt-get -y  install zlib1g-dev 


sudo /usr/bin/pip install --upgrade --force-reinstall  lxml
sudo /usr/bin/pip install --upgrade --force-reinstall  mod_wsgi

sudo apt-get -y install libapache2-mod-wsgi

# setting up sendmail
sudo apt-get -y install sendmail
sudo apt-get -y upgrade sendmail
yes y | sudo sendmailconfig

sudo a2enmod cgi            # enable cgi script
sudo service apache2 restart

# avoid unqalified ServerName error for Ubuntu 14.04
echo "ServerName localhost" | sudo tee /etc/apache2/conf-available/fqdn.conf
sudo a2enconf fqdn
