#/bin/bash

# Description: 
#   get the IP address of the running computer.
#   This is useful to get the public (floating) IP within a virutal machine    
#
external_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)

if [ "$external_ip" == "" ];then
    external_ip=$(curl https://myip.dnsomatic.com/ 2> /dev/null)
fi

echo "$external_ip"
