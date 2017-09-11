rundir=$(dirname $0)
rundir=$(readlink -f $rundir)

deplist="
https://gnupg.org/ftp/gcrypt/npth/npth-1.5.tar.bz2 
https://gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.9.tar.bz2
https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.8.1.tar.bz2
https://gnupg.org/ftp/gcrypt/libassuan/libassuan-2.4.3.tar.bz2
https://gnupg.org/ftp/gcrypt/libksba/libksba-1.3.5.tar.bz2  
https://gnupg.org/ftp/gcrypt/gnupg/gnupg-2.2.0.tar.bz2  
"

#############################################
# install 
#############################################
tmpdir=$(mktemp -d /tmp/tmpdir.install_gnupg2.2_on_centos_SL7.XXXXXXXXX) || { echo "Failed to create temp dir" >&2; exit 1; } 


for url in $deplist; do 
    cd $tmpdir
    filename=$(basename $url)
    foldername=$(basename $filename .tar.bz2)
    curl -O $url
    tar -xvjf $filename
    cd $foldername
    ./configure
    make
    sudo make install
done

cd $rundir
rm -rf $tmpdir
