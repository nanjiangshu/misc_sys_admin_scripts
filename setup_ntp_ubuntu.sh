#!/bin/bash

sudo apt-get install -y ntp
sudo apt install ntpdate
echo "ntpdate ntp.ubuntu.com pool.ntp.org" | sudo tee --append /etc/cron.daily/ntpdate
sudo chmod 755  /etc/cron.daily/ntpdate
sudo /etc/init.d/ntp stop
sudo /etc/cron.daily/ntpdate  
sudo /etc/init.d/ntp start
sudo dpkg-reconfigure tzdata
