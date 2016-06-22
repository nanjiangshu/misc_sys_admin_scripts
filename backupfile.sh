#!/bin/bash
# backup files into a backup directory by adding 
# the modification time of files to the end.
# The extensions for files are kept

progname=`basename $0`
usage="
Usage: $progname  FILE [FILE ...]
                  [-d DIR] [-l LISTFILE] [-z]
Description:
    Backup files by adding the modification time of files to the end of the
    file name
OPTIONS:
    -d DIR        backup the files to path, (default: \$dirname(\$file)/bak)
    -l LISTFILE   file containing a list of filenames, one file per line
    -z            surpass file to gzip

Created 2007-08-15, updated 2014-05-15, Nanjiang Shu

Examples:
    backupfile.sh file1 file2 file3 -d mybak
"
##########################################################################
# ChangeLog 2010-01-14
#    the trailing time added changed to the modification time of the file
#    instead of the current time.
# ChangeLog 2010-02-05
#    The filename should be without ':' and '!'
#    Therefore the time format has been changed
# ChangeLog 2010-04-21 
#    copy only when the file is updated, if the file already exist, do not
#    copy and do not display the message for that file.
# ChangeLog 2010-05-04
#    The external program rootname and getfileext is removed, supplemented by
#    the buildin function
# ChangeLog 2012-09-19
#    Filenames with white spaces are supported as well
# ChangeLog 2014-05-15
#    The default backuppath is change from ./bak to $dirname($file)/bak
##########################################################################

PrintHelp(){
    echo "$usage"
}

if [ $# -lt 1 ]; then
    PrintHelp
    exit
fi

BackupFile(){ # file#{{{
    local file="$1"
    local newfile=

    local TIME=`$stat_exec "$file" | awk '/Modify/{print $2"-"substr($3,1,8)}' | tr ':' '.'`

    local basename=`basename "$1"`
    local rootname=${basename%.*}
    local ext=${basename#*.}
    local backuppath=
    local dirname=

    if [ "$global_backuppath" != "" ];then
        backuppath="$global_backuppath"
    else
        dirname=`dirname $file`
        backuppath="$dirname/bak"
        if [ ! -d "$dirname/bak" ];then
            mkdir -p "$dirname/bak"
        fi
    fi
    newfile="$backuppath/$rootname-$TIME.$ext"
    if [ ! -f "$newfile" ]; then # updated 2010-04-21
        /bin/cp -f "$file" "$newfile"
        if [ $isQuiet -eq 0 ]; then
            echo -e "$file \t\t backuped at ${newfile}"
        fi
    fi
    if [ $isCompress -eq 1 -a ! -f "$newfile.gz" ]; then
        gzip -1fN "$newfile"
        chmod -x "$newfile.gz"
        if [ $isQuiet -eq  0  ]; then
            echo -e "$file \t\t backuped at ${newfile}.gz"
        fi
    fi
}
#}}}

osname=`uname -s`
case $osname in 
    Linux)
        stat_exec=stat
        ;;
    Darwin)
        stat_exec=gstat
        ;;
    *)
        stat_exec=stat
        ;;
esac

global_backuppath=
fileListFile=
fileList=()
isCompress=0
isQuiet=0

isNonOptionArg=0
while [ "$1" != "" ]; do
    if [ $isNonOptionArg -eq 1  ]; then 
        fileList+=("$1")
        isNonOptionArg=0
    elif [ "$1" == "--" ]; then
        isNonOptionArg=1
    elif [ "${1:0:1}" == "-" ]; then
        case "$1" in
            -h | --help) PrintHelp; exit;;
            -d|--d) global_backuppath=$2;shift;;
            -l|--l) fileListFile=$2;shift;;
            -z|--z) isCompress=1;;
            -q|--q) isQuiet=1;;
            -*) echo "Error! Wrong argument: $1">&2; exit;;
        esac
    else
        fileList+=("$1")
    fi
    shift
done

if [ "$global_backuppath" != "" ];then
    if [ ! -d "$global_backuppath" ]; then
        mkdir -p "$global_backuppath"
    fi
fi

if [ "$fileListFile" != ""  ]; then 
    if [ -s "$fileListFile" ]; then 
        while read line
        do
            fileList+=("$line")
        done < $fileListFile
    else
        echo listfile \'$fileListFile\' does not exist or empty. >&2
    fi
fi

numFile=${#fileList[@]}
if [ $numFile -eq 0  ]; then
    echo Input not set! Exit. >&2
    exit 1
fi
for ((i=0;i<numFile;i++));do
    file=${fileList[$i]}
    if [ -f "$file" ]; then
        BackupFile "$file"
    fi
done
