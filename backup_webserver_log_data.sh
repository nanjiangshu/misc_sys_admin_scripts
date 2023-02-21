#!/bin/bash

# backup web-server log data



serverlist="proq3 topcons2 boctopus2 scampi2 pathopred.bioinfo.se pconsc3 prodres subcons predzinc frag1d"
localroot=/mnt/storage/backup/server

exec_cmd(){
    if [ "$dryrun" == 0 ] ;then
        echo "$*"
        eval "$*"
    else
        echo "DRYRUN: $*"
    fi
}

usage="
USAGE: $0 [--localroot PATH] [--dryrun] [webserver1 ... ]
"

isNonOptionArg=0
dryrun=0
while [ "$1" != "" ]; do
    if [ $isNonOptionArg -eq 1  ]; then 
        serverlist="$serverlist $1"
        isNonOptionArg=0
    elif [ "$1" == "--" ]; then
        isNonOptionArg=1
    elif [ "${1:0:1}" == "-" ]; then
        case "$1" in
            -localroot|--localroot) localroot="$2"; shift;;
            -dryrun|--dryrun) dryrun=1;;
            -h|--help) echo "$usage"; exit;;
            -*) echo "Error! Wrong argument: $1">&2; exit;;
        esac
    else
        serverlist="$serverlist $1"
    fi
    shift
done


echo "======backup web-server log data  ======"
echo "Date=`date`"
echo "==================================================="
echo "serverlist=$serverlist"

for server in $serverlist; do 
    localpath=$localroot/$server/proj/pred/static/log/
    remotepath=/var/www/html/$server/proj/pred/static/log/
    if [ ! -d $localpath ];then
        exec_cmd "mkdir -p $localpath"
    fi
    exec_cmd "rsync -auvz -e ssh pcons1:$remotepath/ $localpath/"
done
