sudo ufw allow from 130.237.0.0/16 to any port 22
sudo ufw allow from 130.238.0.0/16 to any port 22
sudo ufw allow from 130.229.0.0/16 to any port 22
sudo ufw allow from 130.237.0.0/16 to any port 2022
sudo ufw allow from 130.238.0.0/16 to any port 2022
sudo ufw allow from 130.229.0.0/16 to any port 2022
sudo ufw allow from 155.4.221.201 to any port 22
sudo ufw allow from 155.4.221.201 to any port 2022
sudo ufw allow from 212.25.149.237 to any port 22
sudo ufw allow from 212.25.149.237 to any port 2022
sudo ufw allow from 130.243.0.0/16 to any port 22
sudo ufw allow from 130.243.0.0/16 to any port 2022
sudo ufw allow from 83.185.46.245 to any port 22
sudo ufw allow from 83.185.46.245 to any port 2022
sudo ufw allow from 212.25.147.10 to any port 22
sudo ufw allow from 212.25.147.10 to any port 2022

sudo ufw allow 80/tcp   # Allow HTTP traffic
sudo ufw allow 443/tcp  # Allow HTTPS traffic
sudo ufw allow from 172.80.0.0/16  # for docker
sudo ufw allow 8800
sudo ufw allow 8081
sudo ufw allow 8080

# Move deny SSH to the end to avoid overriding previous allow rules
sudo ufw deny 22

sudo ufw enable
sudo systemctl enable ufw
sudo ufw status
