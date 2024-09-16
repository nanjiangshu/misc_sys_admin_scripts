#!/bin/bash

# clean data on the web server frontend. 
# pcons1
# Created 2017-09-13, updated 2017-09-13, Nanjiang Shu  
# this script is supposed to be added to the crontab as apache_user

# sudo crontab -u apache_user -e  

echo "======Clean web-server data on the frontend  ======"
echo "Date=`date`"
echo "==================================================="

if [ -d /scratch ];then

    find /scratch -maxdepth 1 -name "seq_*" -type d   -ctime +10 -print0 | xargs -0  rm -rf
    find /scratch -maxdepth 1 -name "boctopus2_*" -type d   -ctime +10 -print0 | xargs -0 rm -rf

fi

serverlist="proq3 topcons2 boctopus2 scampi2 pathopred.bioinfo.se pconsc3 prodres subcons predzinc frag1d"
for server in $serverlist; do 
    datapath=/var/www/html/$server/proj/pred/static/tmp
    if [ -d $datapath  ];then
        find $datapath -maxdepth 1 -type d -ctime +30 -name "tmp_*"  -exec sudo rm -rf {} +
        find $datapath -maxdepth 1 -type f -ctime +30 -name "slurm*" -exec sudo rm -f {} +
    fi
done
