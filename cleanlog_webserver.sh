#!/bin/bash

# clean log located at /var/log/httpd on the webserver
# pcons3
# Created 2021-02-09, updated 2021-02-09, Nanjiang Shu 
# this script is supposed to be added to the crontab as root

# sudo crontab -e

if [ -d /var/log/httpd ];then
    find /var/log/httpd -maxdepth 1 -name "*log-2*" -type f  -ctime +1 -print0 | xargs -0  rm -f
fi
if [ -d /var/log/apache2 ];then
    find /var/log/apache2 -maxdepth 1 -name "*log.*.gz" -type f  -ctime +1 -print0 | xargs -0  rm -f
fi

