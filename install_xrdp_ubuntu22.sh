sudo apt update
sudo apt upgrade -y
sudo apt install xrdp -y
sudo systemctl status xrdp
sudo adduser $USER xrdp

sudo apt install xfce4 xfce4-goodies -y
echo "xfce4-session" > ~/.xsession

sudo touch /etc/xrdp/startwm.sh
echo "startxfce4" | sudo tee --append /etc/xrdp/startwm.sh
