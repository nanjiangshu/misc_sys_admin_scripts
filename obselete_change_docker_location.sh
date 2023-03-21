#!/bin/bash
# change docker lib to another location with larger storage

# this is not the recommended way, use daemon configuration instead 
# https://docs.docker.com/config/daemon/
# since otherwise the settings will be overwrite when dockerd is updated.

usage="
USAGE: $0: <new_docker_path>

Example:

$0 /media/storage/data/docker
"

if [ "$1" == "" ];then
    echo "$usage"
    exit 1
fi
new_docker_path=$1


sudo systemctl stop docker.service
sudo systemctl stop docker.socket


sudo mkdir -p $new_docker_path

sudo sed -i 's,ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock,ExecStart=/usr/bin/dockerd -g '"$new_docker_path"' -H fd:// --containerd=/run/containerd/containerd.sock,' /lib/systemd/system/docker.service

sudo rsync -aqxP /var/lib/docker/ $new_docker_path/

sudo systemctl daemon-reload
sudo systemctl start docker
