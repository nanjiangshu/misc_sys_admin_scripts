#!/bin/bash

sudo systemctl stop slurmctld
sudo systemctl stop slurmd
sudo systemctl start slurmctld
sudo systemctl start slurmd

hostname=$(hostname -s)
sudo scontrol update nodename=$hostname state=idle 
sinfo -R
