# install dependencies on ubuntu22 when the after the VM is created
rundir=$(dirname $0)
rundir=$(readlink -f $rundir)

sudo apt install x11-apps -y
sudo apt install firefox -y
sudo apt install keychain -y
sudo apt install jq -y
sudo apt install samtools -y
sudo apt install tree -y
sudo apt install imagemagick -y

bash ${rundir}/install_docker_ubuntu.sh
bash ${rundir}/install_go_on_linux.sh 1.22.2
bash ${rundir}/install_singularity_on_linux.sh
bash ${rundir}/install_miniconda_on_linux.sh
bash ${rundir}/install_et_ubuntu.sh
bash ${rundir}/setup_ntp_ubuntu.sh