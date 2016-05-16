#!/bin/bash
#started 2015-02-10

# installing mod_wsgi
sudo yum install httpd-devel
sudo yum install mod_wsgi


# for set limitation for maximum connections
# copy pcons2:/etc/yum.repos.d/* to pcons1:/yum.repos.d/*
sudo yum install  --nogpgcheck mod_limitipconn






