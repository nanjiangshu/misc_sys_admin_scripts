sudo ufw allow from 130.237.0.0/16 to any port 22
sudo ufw allow from 130.238.0.0/16 to any port 22
sudo ufw allow from 130.229.169.0/16 to any port 22
sudo ufw allow from 130.237.0.0/16 to any port 2022
sudo ufw allow from 130.238.0.0/16 to any port 2022
sudo ufw allow from 130.229.169.0/16 to any port 2022
sudo ufw allow from 155.4.221.201 to any port 22
sudo ufw allow from 155.4.221.201 to any port 2022
sudo ufw deny 22
sudo ufw enable
sudo systemctl enable ufw
sudo ufw status
