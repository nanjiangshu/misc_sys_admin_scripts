#!/bin/bash

# Description: Run local script on the remote server via ssh

set -e
g_user=ubuntu
progname=`basename $0`
size_progname=${#progname}
wspace=`printf "%*s" $size_progname ""`
usage="
Usage:  $progname -script FILE host [host ...]
Options:
  -u, --user   USER   Set the username
  -l, --list   FILE   Set the file contains a list of hosts
  -s, --script FILE   Set the script file
  -sudo               Wether run as sudo
  -h, --help          Print this help message and exit

Created 2022-01-21, updated 2022-01-21, Nanjiang Shu
"

RunScriptOnRemote() {
    local host=$1
    local host_with_user=
    case $host in
        *@*) host_with_user=$host ;;
        *) host_with_user=${g_user}@${host};;
    esac

    if [ $isQuiet -eq 0 ] ;then
        echo "Running $scriptfile on $host_with_user"
    fi
    cat $scriptfile | ssh -o StrictHostKeyChecking=no $host_with_user $sudo bash
}

hostListFile=
hostList=()
isQuiet=0
sudo=

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
            -u|--user) user=$2;shift;;
            -l|--list) hostListFile=$2;shift;;
            -s|--script) scriptfile=$2;shift;;
            -q|--quiet) isQuiet=1;;
            -sudo|--sudo) sudo=sudo;;
            -*) echo "Error! Wrong argument: $1">&2; exit;;
        esac
    else
        hostList+=("$1")
    fi
    shift
done


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
    RunScriptOnRemote "$host"
done
