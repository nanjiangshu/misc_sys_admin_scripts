#!/bin/bash 
function PrintHelp()
{
    echo "Usage: sawpfile file1 file2"
    echo "  shell script for sawping the content of two files"
    echo "Last modified 2006-05-02, Nanjiang Shu"
}

if [ $# -lt 2 ]; then
    PrintHelp
    exit
fi

tmpfile=$(basename $0).$$

i=0;
while [ "$1" != "" ]; do
	case $1 in
		-h | --help) PrintHelp
		break
        exit
        ;;
        *) file[$i]=$1
        let i++;
	esac
    # Shift all the parameters down by one
	shift
done

mv ${file[0]} $tmpfile
mv ${file[1]} ${file[0]} 
mv ${tmpfile} ${file[1]}
