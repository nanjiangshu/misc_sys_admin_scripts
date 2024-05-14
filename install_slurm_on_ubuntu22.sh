#!/bin/bash

rundir=`dirname $0`
rundir=`readlink -f $rundir`

hostname=$(hostname -s)

sudo apt install munge slurm-wlm  -y 

# copy slurm files
cat $rundir/slurm.conf.ubuntu22.example | sed "s/wks-nj/$hostname/g" | sudo tee /etc/slurm/slurm.conf

# start the service

sudo systemctl enable slurmd.service
sudo systemctl start slurmd.service

sudo systemctl enable slurmctld.service
sudo systemctl start slurmctld.service

bash $rundir/reload_slurm.sh

sudo scontrol update nodename=$hostname state=idle 