
curl -fsSL https://get.docker.com/ | sh

if [ ! -f   /usr/local/bin/docker-compose ];then
    curl -L https://github.com/docker/compose/releases/download/2.20.2/docker-compose-`uname -s`-`uname -m` > /tmp/docker-compose; chmod +x /tmp/docker-compose; sudo cp /tmp/docker-compose /usr/local/bin/docker-compose
fi


mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose && chmod +x ~/.docker/cli-plugins/docker-compose
