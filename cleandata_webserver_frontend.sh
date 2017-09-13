#!/bin/bash

# clean data on the web server frontend. 
# pcons1
# Created 2017-09-13, updated 2017-09-13, Nanjiang Shu  

if [ -d /scratch ];then

    find /scratch -maxdepth 1 -name "seq_*" -type d   -ctime +10 -print0 | xargs -0 sudo rm -rf
    find /scratch -maxdepth 1 -name "boctopus2_*" -type d   -ctime +10 -print0 | xargs -0 sudo rm -rf   

fi

