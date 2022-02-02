#!/bin/bash

sudo yum clean all

sudo yum -y update

sudo yum -y install httpd httpd-devel

sudo yum install firewall-config

sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload

sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl status httpd

# others 
sudo yum install wget tar make gcc -y
