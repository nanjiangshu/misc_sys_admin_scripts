sudo yum install python3-devel
sudo dnf install httpd -y

sudo dnf install redhat-rpm-config
sudo dnf -y install python3-mod_wsgi
sudo systemctl restart httpd.service

openssl rand -base64 40 | sudo tee /etc/django_pro_secret_key.txt 
