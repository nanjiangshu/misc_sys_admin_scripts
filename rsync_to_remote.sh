#!/bin/bash

# Description: rsync file/folder to the remote

set -e
g_user=ubuntu
progname=`basename $0`
size_progname=${#progname}
wspace=`printf "%*s" $size_progname ""`
usage="
Usage:  $progname -local PATH -remote PATH host [host ...]
Options:
  -u, --user   USER   Set the username
  -l, --list   FILE   Set the file contains a list of hosts
  -h, --help          Print this help message and exit

Created 2022-01-21, updated 2022-01-21, Nanjiang Shu
"

RunCmd() {
    if [ $isQuiet -eq 0 ];then
        echo "$*"
    fi
    eval "$*"
}

RsyncToRemote() {
    local host=$1
    local host_with_user=
    case $host in
        *@*) host_with_user=$host ;;
        *) host_with_user=${g_user}@${host};;
    esac
    if [ -d "$local_path" ];then
        if [[ ! $local_path == */ ]];then
            local_path=$local_path/
        fi
        if [[ ! $remote_path == */ ]];then
            remote_path=$remote_path/
        fi
    fi
    RunCmd "ssh -o StrictHostKeyChecking=no $host_with_user mkdir -p $remote_path"
    RunCmd "rsync -auvz -e \"ssh -o StrictHostKeyChecking=no\" $local_path $host_with_user:$remote_path"
}

hostListFile=
hostList=()
local_path=
remote_path=
isQuiet=0

if [ $# -lt 1 ]; then
    echo "$usage"
    exit
fi

isNonOptionArg=0
while [ "$1" != "" ]; do
    if [ $isNonOptionArg -eq 1  ]; then 
        hostList+=("$1")
        isNonOptionArg=0
    elif [ "$1" == "--" ]; then
        isNonOptionArg=1
    elif [ "${1:0:1}" == "-" ]; then
        case "$1" in
            -h|--help) echo "$usage"; exit;;
            -u|--user) g_user=$2;shift;;
            -l|--list) hostListFile=$2;shift;;
            -local|--local) local_path=$2;shift;;
            -remote|--remote) remote_path=$2;shift;;
            -q|--quiet) isQuiet=1;;
            -*) echo "Error! Wrong argument: $1">&2; exit;;
        esac
    else
        hostList+=("$1")
    fi
    shift
done

if [ "$local_path" == "" ];then
    echo "local_path not set. exit!"
    exit 1
fi
if [ "$remote_path" == "" ];then
    echo "remote_path not set. exit!"
    exit 1
fi

if [ "$hostListFile" != ""  ]; then 
    if [ -s "$hostListFile" ]; then 
        while read line
        do
            hostList+=("$line")
        done < $hostListFile
    else
        echo listfile \'$hostListFile\' does not exist or empty. >&2
    fi
fi

numHost=${#hostList[@]}
if [ $numHost -eq 0  ]; then
    echo Input not set! Exit. >&2
    exit 1
fi

for ((i=0;i<numHost;i++));do
    host=${hostList[$i]}
    RsyncToRemote "$host"
done
