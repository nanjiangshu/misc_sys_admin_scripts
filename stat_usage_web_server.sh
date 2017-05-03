#!/bin/bash

# Filename: 
# Description:  usage analysis of web-servers
# Author: Nanjiang Shu (nanjiang.shu@scilifelab.se)

progname=`basename $0`
size_progname=${#progname}
wspace=`printf "%*s" $size_progname ""` 
usage="
Usage:  $progname method [method ...]
Options:
  -o       OUTFILE  Set output file
  -start-date STR   Set the start date for analysis, in the format 2015-01-01
  -end-date   STR   Set the end date for analysis
  -h, --help        Print this help message and exit

Created 2017-05-03, updated 2017-05-03, Nanjiang Shu
"

UsageAna(){
    local method=$1
    case $method in 
        topcons2|proq3|pconsc3|subcons|prodres|scampi2|boctopus2)
            infile=/var/www/html/$method/proj/pred/static/log/submitted_seq.log
            uniqiplistfile=$tmpdir/uniqiplist.$method.txt
            anafile=$tmpdir/uniqidlist.$method.ana.txt
            awk -F "\t" -v d1=$startdate -v d2=$enddate '{ip=$3; split($1,ss," "); date=ss[1]; gsub(/-/, "", date); if(date>=d1 && date<=d2) {print ip}}' $infile | sort -u > $uniqiplistfile
            my_ip2country.py -l  $uniqiplistfile -show-eu > $anafile
            numUser=$(awk -F "\t" '{print $1}' $anafile | sort -u |wc -l )
            numCountry=$(awk -F "\t" '{print $2}' $anafile | sort -u |wc -l )
            numUserEU=$(awk -F "\t" '{if ($3=="EU") print $2}' $anafile | wc -l )
            #echo -e "#Method\tNumUser\tNumCountry\tNumUser_EU\tPercentEU"
            percentEU=$(python -c "print float($numUserEU)/$numUser*100")
            echo -e "$method\t$numUser\t$numCountry\t$numUser_EU\t$percentEU"
            ;;
    esac
}

if [ $# -lt 1 ]; then
    PrintHelp
    exit
fi

methodList=()
startdate=
enddate=

tmpdir=$(mktemp -d /tmp/tmpdir.stat_usage_web_server.XXXXXXXXX) || { echo "Failed to create temp dir" >&2; exit 1; }
trap 'rm -rf "$tmpdir"' INT TERM EXIT


isNonOptionArg=0
while [ "$1" != "" ]; do
    if [ $isNonOptionArg -eq 1 ]; then 
        methodList+=("$1")
        isNonOptionArg=0
    elif [ "$1" == "--" ]; then
        isNonOptionArg=true
    elif [ "${1:0:1}" == "-" ]; then
        case $1 in
            -h | --help) PrintHelp; exit;;
            -start-date|--start-date) startdate=$2;shift;;
            -end-date|--end-date) enddate=$2;shift;;
            -q|-quiet|--quiet) isQuiet=1;;
            -*) echo Error! Wrong argument: $1 >&2; exit;;
        esac
    else
        methodList+=("$1")
    fi
    shift
done


numMethod=${#methodList[@]}
if [ $numMethod -eq 0  ]; then
    echo Input not set! Exit. >&2
    exit 1
fi

echo -e "#Method\tNumUser\tNumCountry\tNumUser_EU\tPercentEU"

for ((i=0;i<numMethod;i++));do
    method=${methodList[$i]}
    UsageAna "$method"
done

