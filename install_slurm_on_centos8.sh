#!/bin/bash

rundir=`dirname $0`
rundir=`readlink -f $rundir`

hostname=$(hostanme)

export MUNGEUSER=991
groupadd -g $MUNGEUSER munge
useradd  -m -c "MUNGE Uid 'N' Gid Emporium" -d /var/lib/munge -u $MUNGEUSER -g munge  -s /sbin/nologin munge
export SLURMUSER=992
groupadd -g $SLURMUSER slurm
useradd  -m -c "SLURM workload manager" -d /var/lib/slurm -u $SLURMUSER -g slurm  -s /bin/bash slurm

yum install epel-release
yum install munge munge-libs munge-devel -y


yum install rng-tools -y
rngd -r /dev/urandom

/usr/sbin/create-munge-key -r

dd if=/dev/urandom bs=1 count=1024 > /etc/munge/munge.key
chown munge: /etc/munge/munge.key
chmod 400 /etc/munge/munge.key


chown -R munge: /etc/munge/ /var/log/munge/
chmod 0700 /etc/munge/ /var/log/munge/

systemctl enable munge
systemctl start munge

tmpdir=$(mktemp -d /tmp/tmpdir.install_slurm_on_centos8.XXXXXXXXX) || { echo "Failed to create temp dir" >&2; exit 1; }

cd $tmpdir

wget https://download.schedmd.com/slurm/slurm-20.02.7.tar.bz2
rpmbuild -ta slurm-20.02.7.tar.bz2
cd ~/rpmbuild/RPMS/x86_64/
sudo yum --nogpgcheck localinstall *.rpm

# fix file permissions

mkdir -p /var/spool/slurmctld
mkdir -p /var/spool/slurmd
chown slurm: /var/spool/slurm
chown slurm: /var/spool/slurmctld
chown slurm: /var/spool/slurmd

chmod 755 /var/spool/slurmctld
touch /var/log/slurmctld.log
chown slurm: /var/log/slurmctld.log
touch /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log
chown slurm: /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log

chmod 755 /var/spool/slurmd
touch /var/log/slurmd.log
chown slurm: /var/log/slurmd.log

# copy slurm files
cat $rundir/slurm.conf.centos.example | sed "s/pcons1.scilifelab.se/$hostname/g" | tee /etc/slurm/slurm.conf
cat $rundir/cgroup.conf.centos8.example | tee /etc/slurm/cgroup.conf

# start the service

systemctl enable slurmd.service
systemctl start slurmd.service

systemctl enable slurmctld.service
systemctl start slurmctld.service

rm -rf $tmpdir

