sudo yum install python3-devel
sudo dnf install httpd -y

sudo dnf install redhat-rpm-config
sudo dnf -y install python3-mod_wsgi
sudo systemctl restart httpd.service

