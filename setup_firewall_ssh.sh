sudo ufw allow from 130.237.0.0/16 to any port 22
sudo ufw allow from 130.238.0.0/16 to any port 22
sudo ufw allow from 130.229.169.0/16 to any port 22
sudo ufw allow from 130.237.0.0/16 to any port 2022
sudo ufw allow from 130.238.0.0/16 to any port 2022
sudo ufw allow from 130.229.169.0/16 to any port 2022
sudo ufw allow from 155.4.221.201 to any port 22
sudo ufw allow from 155.4.221.201 to any port 2022
sudo ufw allow from 212.25.149.237 to any port 22
sudo ufw allow from 212.25.149.237 to any port 2022
sudo ufw allow from 130.243.159.173/16 to any port 22
sudo ufw allow from 130.243.159.173/16 to any port 2022
sudo ufw allow from 83.185.46.245 to any port 22
sudo ufw allow from 83.185.46.245 to any port 2022
sudo ufw allow 80/tcp   # Allow HTTP traffic
sudo ufw allow 443/tcp  # Allow HTTPS traffic
sudo ufw allow 8800
sudo ufw allow 8081
sudo ufw allow 8080

# Allow any connection from Docker
dockerSubnet=$(docker network inspect bridge | grep Subnet | awk '{print $2}' | awk -F\" '{print $2}')
if [ "$dockerSubnet" != "" ]; then
    sudo ufw allow from $dockerSubnet
fi

sudo ufw deny 22
sudo ufw enable
sudo systemctl enable ufw
sudo ufw status
