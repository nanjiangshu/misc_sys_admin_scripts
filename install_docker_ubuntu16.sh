
curl -fsSL https://get.docker.com/ | sh

if [ ! -f   /usr/local/bin/docker-compose ];then
    curl -L https://github.com/docker/compose/releases/download/1.23.1/docker-compose-`uname -s`-`uname -m` > /tmp/docker-compose; chmod +x /tmp/docker-compose; sudo cp /tmp/docker-compose /usr/local/bin/docker-compose
fi