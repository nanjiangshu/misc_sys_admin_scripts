#!/bin/bash

cd /usr/bin

filelist="
basename
sort
"

for file in $filelist; do
    if [ ! -f $file ];then
        sudo ln -s /bin/$file $file
    fi
done
