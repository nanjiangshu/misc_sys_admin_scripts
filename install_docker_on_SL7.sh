rundir=$(dirname $0)
rundir=$(readlink -f $rundir)

sudo yum install -y yum-utils device-mapper-persistent-data lvm2

sudo yum-config-manager \
        --add-repo \
            https://download.docker.com/linux/centos/docker-ce.repo

sudo yum-config-manager --enable docker-ce-edge

sudo yum-config-manager --enable docker-ce-test

sudo yum makecache fast


# install container-selinux2.9
tmpdir=$(mktemp -d /tmp/tmpdir.install_docker_on_SL7.XXXXXXXXX) || { echo "Failed to create temp dir" >&2; exit 1; }

cd $tmpdir
url=ftp://ftp.icm.edu.pl/vol/rzm6/linux-scientificlinux/7x/external_products/extras/x86_64/container-selinux-2.9-4.el7.noarch.rpm

curl -O $url
sudo rpm -ivh container-selinux-2.9-4.el7.noarch.rpm 

cd $rundir

rm -rf $tmpdir

# install docker
sudo yum install docker-ce

# start docker on system boot
sudo systemctl enable docker.service 
sudo systemctl start docker  

sudo usermod -aG docker nanjiang
sudo systemctl restart docker

# install docker-compose
tmpdir=$(mktemp -d /tmp/tmpdir.install_docker_on_SL7.XXXXXXXXX) || { echo "Failed to create temp dir" >&2; exit 1; }

curl -L https://github.com/docker/compose/releases/download/1.16.0/docker-compose-`uname -s`-`uname -m` > $tmpdir/docker-compose

sudo cp $tmpdir/docker-compose /usr/local/bin/
sudo chmod +x /usr/local/bin/docker-compose

rm -rf $tmpdir
