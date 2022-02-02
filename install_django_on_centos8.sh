sudo yum install python3-devel
sudo dnf install mod_wsgi httpd -y

sudo dnf install redhat-rpm-config
sudo pip3 install mod_wsgi
sudo systemctl restart httpd.service

