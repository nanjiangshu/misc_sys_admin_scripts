#!/bin/bash

# clean archived result on the web server frontend. 
# pcons1
# 2024-09-16
# this script is supposed to be added to the crontab as apache_user

# sudo crontab -u apache_user -e

echo "======Clean archived results on the web-server (frontend)  ======"
echo "Date=`date`"
echo "================================================================="


serverlist="proq3 topcons2 boctopus2 scampi2 pathopred.bioinfo.se pconsc3 prodres subcons predzinc frag1d"
for server in $serverlist; do 
    datapath=/var/www/html/$server/proj/pred/static/result/cache
    if [ -d $datapath ];then
        find $datapath -type f -ctime +365 -name "*.zip" -exec sudo rm -f {} +
    fi
done
