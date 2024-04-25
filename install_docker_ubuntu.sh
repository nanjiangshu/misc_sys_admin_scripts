
curl -fsSL https://get.docker.com/ | sh

sudo usermod -aG docker $USER

# install docker compose CLI
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.26.0/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose && chmod +x ~/.docker/cli-plugins/docker-compose
