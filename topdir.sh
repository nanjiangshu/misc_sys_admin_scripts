#!/bin/bash
# Filename: topdir.sh
# Description: Show the largest files or folders in the path 
# Author: Nanjiang Shu (nanjiang.shu@scilifelab.se)

# ChangeLog 2011-11-20 #{{{
#    topdir is now working with files with whitespaces
# ChangeLog 2014-09-26
#    using byte2human.awk as byte2human, so that it is not platform dependant
#}}}

progname=`basename $0`
size_progname=${#progname}
wspace=`printf "%*s" $size_progname ""` 

usage="
Usage: $progname [[-d] DIR] [-n INT] 

Description: 
    Show the largest files or folders in the path

OPTIONS:
  -d DIR       Path for listing dirs, (default: ./)
  -n INT       Number of dirs to show, (default: 10)
  -h, --help   Print this help message and exit

Created 2007-08-17, updated 2013-05-20, Nanjiang Shu
"
PrintHelp() { #{{{
    echo "$usage"
}
#}}}
IsProgExist(){ #{{{
    # usage: IsProgExist prog
    # prog can be both with or without absolute path
    type -P $1 &>/dev/null \
        || { echo The program \'$1\' is required but not installed. \
        Aborting $0 >&2; exit 1; }
    return 0
}
#}}}
ShowLargestFolderOrFile() { #{{{
    case $os in 
        Darwin|Leo*|OpenBSD*)
            /usr/bin/find "$path" -maxdepth 1 -print0 |\
                xargs -0 /usr/bin/du -k -d 0  | /usr/bin/sort -nr |\
                head -n $topN > $tmpfile_size_fname
            ;;
        Linux*|Cygwin*)
            /usr/bin/du "$path" --max-depth=1 -a -b | sort -nr |\
                head -n $topN > $tmpfile_size_fname
            ;;
        *)
            echo Operating System $os not supported. Exit. >&2
            return 1
            ;;
    esac


    if [ -s "$tmpfile_size_fname" ]; then 
        case $os in 
            Darwin|Leo*|OpenBSD*)
                cat $tmpfile_size_fname | cut -f 1 | awk '{print $1*1024}' |\
                    byte2human.awk > $tmpfile_size
                ;;
            Linux*|Cygwin*)
                cat $tmpfile_size_fname | cut -f 1 | byte2human.awk > $tmpfile_size
        esac
        cat $tmpfile_size_fname | cut -f 2-  > $tmpfile_fname
        paste $tmpfile_size $tmpfile_fname
    fi
} 
#}}}
path=./
topN=10

while [ "$1" != "" ]; do
    case $1 in 
        -h | --help) PrintHelp; exit;;
        -d|--d|-dir|--dir) path="$2"; shift;;
        -n|--n|-num|--num) topN="$2"; shift;; 
        *)
        path="$1";;
    esac
    shift
done

IsProgExist byte2human.awk

if [ ! -d "$path" ]; then
    echo path \'$path\' is not a directory or does not exists >&2
    exit 1
fi

os=`uname -s` 
tmpdir=$(mktemp -d /tmp/tmpdir.$progname.XXXXXXXXX) \
    || { echo Failed to create temp dir >&2; exit 1; }  

trap 'rm -rf "$tmpdir"' INT TERM EXIT

tmpfile_size_fname=$tmpdir/size-filename.txt
tmpfile_size=$tmpdir/size.txt
tmpfile_fname=$tmpdir/filename.txt

ShowLargestFolderOrFile "$path"

rm -rf $tmpdir
