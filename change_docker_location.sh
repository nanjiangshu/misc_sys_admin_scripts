#!/bin/bash
# change docker lib to another location with larger storage

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

if [ ! -d "$new_docker_path" ];then
    sudo mkdir -p "$new_docker_path"
fi

if [ ! -s /etc/docker/daemon.json ];then
    echo "{}" | sudo tee /etc/docker/daemon.json
fi
cat /etc/docker/daemon.json | jq ". + {\"data-root\": \"$new_docker_path\"}" | sudo tee /etc/docker/daemon.json

sudo rsync -aqxP /var/lib/docker/ "$new_docker_path"/

sudo systemctl daemon-reload
sudo systemctl start docker
