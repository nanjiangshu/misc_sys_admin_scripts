#!/bin/bash

# format the block storage /dev/vdb
sudo fdisk /dev/vdb # n then w
sudo mkfs -t ext4 /dev/vdb1 
echo "/dev/vdb1  /scratch ext4 defaults,noatime,_netdev,nofail 0 2" | sudo tee --append /etc/fstab
sudo mkdir /scratch
sudo mount -a 

