#!/bin/bash

# format the block storage /dev/vdb
usage="
$0 DEV MountFolder

e.g.

$0 vdb /media/storage
"
dev=$1
mountpath=$2

if [ "$dev" == "" -o "$mountpath" == "" ];then
    echo "$usage"
    exit 1
fi

sudo fdisk /dev/${dev} # n then w
sudo mkfs -t ext4 /dev/${dev}1 
echo "/dev/${dev}1  $mountpath ext4 defaults,noatime,_netdev,nofail 0 2" | sudo tee --append /etc/fstab
sudo mkdir $mountpath
sudo mount -a 

