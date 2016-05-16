#!/bin/bash

sudo yum install -y ntp
echo "ntpdate ntp.ubuntu.com pool.ntp.org" | sudo tee --append /etc/cron.daily/ntpdate
sudo chmod 755  /etc/cron.daily/ntpdate

sudo systemctl enable ntpd.service
sudo /etc/cron.daily/ntpdate  
sudo systemctl start ntpd.service
sudo timedatectl set-timezone Europe/Stockholm
