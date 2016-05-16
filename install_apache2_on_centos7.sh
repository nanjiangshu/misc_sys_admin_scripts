#!/bin/bash

sudo yum clean all

sudo yum -y update

sudo yum -y install httpdo

sudo yum install firewall-config

sudo firewall-cmd --permanent --add-port=80/tcp

sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl status httpd
