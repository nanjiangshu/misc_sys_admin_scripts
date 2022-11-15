#!/bin/bash 
# Description: Change the port of backend of the protein prediction webserver
# from 80 to 8001
# for Ubuntu and Debian system


sed -i 's/^Listen 80$/Listen 8001/g' /etc/apache2/ports.conf
sed -i 's/^<VirtualHost \*:80>$/<VirtualHost \*:8001>/g' /etc/apache2/sites-available/000-default.conf
sed -i 's/^<VirtualHost \*:80>$/<VirtualHost \*:8001>/g' /etc/apache2/conf-available/web_common_backend.conf
service restart apache2
