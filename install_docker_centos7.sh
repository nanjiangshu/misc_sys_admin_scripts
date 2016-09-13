#!/bin/bash

# sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
# [dockerrepo]
# name=Docker Repository
# baseurl=https://yum.dockerproject.org/repo/main/fedora/$releasever/
# enabled=1
# gpgcheck=1
# gpgkey=https://yum.dockerproject.org/gpg
# EOF
# 
# sudo yum install -y docker-engine
# sudo systemctl enable docker.service
# sudo systemctl start docker
# sudo usermod -aG docker $USER; sudo systemctl restart docker;

curl -fsSL https://get.docker.com/ | sh
if [ ! -f   /usr/local/bin/docker-compose ];then
    curl -L https://github.com/docker/compose/releases/download/1.8.0-rc1/docker-compose-`uname -s`-`uname -m` > /tmp/docker-compose; chmod +x /tmp/docker-compose; sudo cp /tmp/docker-compose /usr/local/bin/docker-compose
fi
