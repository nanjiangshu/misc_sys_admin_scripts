#!/bin/bash

rundir=`dirname $0`

cd ~/software/misc_sys_admin_scripts
git pull --all

bash ./install_dep_scampi2_on_ubuntu.sh

# install the scampi2 package
mkdir -p /media/storage/software
pushd /media/storage/software/
git clone https://github.com/ElofssonLab/scampi2
cd scampi2
./install.sh
popd

pushd /var/www/html/web_common_backend/proj/pred/app/soft
ln -s /media/storage/software/scampi2 .
ln -s /media/storage/data/blastdb .
popd

