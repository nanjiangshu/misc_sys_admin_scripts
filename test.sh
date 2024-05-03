source ./utils.sh

usage="""
USAGE: $0 mode [args]

mode: 
    compare_version <version1> <version2>
"""

if [ "$1" == "" ]; then
    echo "$usage"
    exit
fi

if [ "$1" == "compare_version" ] # test compare_version
then 
    usage1="""
args:
    version1: version string 1
    version2: version string 2
Example:
    $0 compare_version 1.1.0 1.0.1
"""
    if [ "$2" == "" ] || [ "$3" == "" ]; then
        echo "$usage"
        echo "$usage1"
        exit
    fi
    v1="$2"
    v2="$3"
    cmp=$(compare_version "$v1" "$v2")
    if [ "$cmp" != "less" ]; then
        echo "$v1 is greater than or equal to $v2" 
    else
        echo "$v1 is not greater than $v2"
    fi
fi