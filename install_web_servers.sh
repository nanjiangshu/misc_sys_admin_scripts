#!/usr/bin/env bash

# Filename: 
# Description:  install web-servers
# Author: Nanjiang Shu (nanjiang.shu@scilifelab.se)

set -e
#set -x
rundir=`dirname $0`
progname=`basename $0`
size_progname=${#progname}
wspace=`printf "%*s" $size_progname ""`
usage="
Usage:  $progname [-w webserver-base-dir] method [method ...]
Options:
  -w <dir>          Set the base directory of the web server code base.
  -h, --help        Print this help message and exit

Created 2022-02-03, updated 2022-02-03, Nanjiang Shu
"


nodename=`uname -n`

case $nodename in 
    pcons*) webserver_base=/big/server/var/www;;
    dev-web*) webserver_base=/software/server;;
    *) webserver_base=/data3/server;;
esac



if [ $# -lt 1 ]; then
    echo "$usage"
    exit
fi

methodList=()
isDebug=0
url_base="https://github.com/NBISweden"

tmpdir=$(mktemp -d /tmp/tmpdir.install_web_servers.XXXXXXXXX) || { echo "Failed to create temp dir" >&2; exit 1; }

#trap 'rm -rf "$tmpdir"' INT TERM EXIT
ipaddress=$(curl ifconfig.me)

InstallWebServer(){
    local method="$1"

    local repo_method_name=
    local servername=
    local isBackend=0

    case $method in
        *web_common_backend*) 
        isBackend=1
        repo_method_name=common-backend
        ;;
        *) repo_method_name=$method;;
    esac

    local reponame="predictprotein-webserver-${repo_method_name}"
    local git_url="${url_base}/${reponame}"

    case $method in
        boctopus2) servername=dev.boctopus.bioshu.se;;
        scampi2) servername=dev.scampi.bioshu.se;;
        *web_common_backend*) servername=$ipaddress;;
        *) servername=dev.${method}.bioshu.se;;
    esac


    pushd $webserver_base
    if [ ! -d $reponame ];then
        git clone "$git_url"
    else
        echo "${webserver_base}/${reponame} exists."
    fi
    cd $reponame
    git pull --all --prune
    if [ ! -d env ] ;then 
        bash setup_virtualenv.sh
    fi
    source env/bin/activate
    bash init.sh
    deactivate
    cd proj
    echo $servername >> allowed_host_dev.txt
    ln -sf dev_settings.py settings.py
    popd


    # creating symlink to the web server code base
    pushd /var/www/html
    if [ -L ${method} ] && [ -e ${method} ];then
        echo "/var/www/html/$method exists. Ingore creating symlink!"
    else
        sudo ln -sfn ${webserver_base}/${reponame} $method
    fi
    popd

    # creating config files
    local exampleconf=${rundir}/topcons2.apache2.conf.example
    if [ -d /etc/httpd ];then
        exampleconf=${rundir}/topcons2.httpd.conf.example
    fi
    local conffile=/etc/httpd/conf.d/${method}.conf
    if [ ! -s $conffile ] ;then
        sed "s/topcons2/${method}/g" $exampleconf | sed "s/dev.topcons.bioshu.se/${servername}/g" | sudo tee $conffile 1> /dev/null
    fi

    if [ "$isBackend" -eq 1 ];then
        local exampleconf=${rundir}/web_common_backend.conf.example 
        local conffile=/etc/apache2/conf.d/${method}.conf
        if [ ! -s $conffile ] ;then
            sed "s/90.147.102.44/${servername}/g" | sudo tee $conffile 1> /dev/null
        fi
    fi  
}


isNonOptionArg=0
while [ "$1" != "" ]; do
    if [ $isNonOptionArg -eq 1 ]; then 
        methodList+=("$1")
        isNonOptionArg=0
    elif [ "$1" == "--" ]; then
        isNonOptionArg=true
    elif [ "${1:0:1}" == "-" ]; then
        case $1 in
            -h | --help) echo "$usage"; exit;;
            -w) webserver_base=$2;shift;;
            -q|-quiet|--quiet) isQuiet=1;;
            -debug|--debug) isDebug=1;;
            -*) echo Error! Wrong argument: $1 >&2; exit;;
        esac
    else
        methodList+=("$1")
    fi
    shift
done



numMethod=${#methodList[@]}
numSpecialCountry=${#specialCountryList[@]}
if [ $numMethod -eq 0  ]; then
    echo Input not set! Exit. >&2
    exit 1
fi

for ((im=0;im<numMethod;im++));do
    method=${methodList[$im]}
    InstallWebServer "$method"
done


if [ $isDebug -eq 0 ]; then
    rm -rf $tmpdir
else
    echo "Temporary files are kept at $tmpdir"
fi
