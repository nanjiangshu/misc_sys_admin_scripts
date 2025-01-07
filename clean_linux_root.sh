#!/bin/bash

#This script helps to clean the root partition of the Linux VM, especially when the root partition has only 20 GB

# 1. clean logs 
#
sudo journalctl --vacuum-time=7d
sudo rm /var/log/*.gz

# 2. setup log rotate
#
sudo logrotate -f /etc/logrotate.conf

# 3. remote snap
#
sudo snap remove --purge firefox

