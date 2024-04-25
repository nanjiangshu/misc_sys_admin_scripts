# install dependencies on ubuntu22 when the after the VM is created


sudo apt install x11-apps -y
sudo apt install firefox -y

bash ./install_docker_ubuntu.sh
bash ./install_go_on_linux.sh 1.22.2
bash ./install_et_ubuntu.sh


