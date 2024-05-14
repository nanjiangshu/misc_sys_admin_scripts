#!/bin/bash
# install the pfamfullseqdb and pfam databases on the remote server
# the version of the pfamfullseqdb and pfam databases should be the same
usage="""
USAGE: $0 <version> <HOST> [<HOST> ...] 
"""

if [ "$#" -lt 2 ]; then
    echo "$usage"
    exit 1
fi

version="$1"
shift
hostlist=("$@")
echo "Pfam version: $version"
echo "Remote host list:"
for host in "${hostlist[@]}"; do
    echo "    $host"
done

rundir=$(dirname $0)
rundir=$(realpath $rundir)

function install_pfamfullseqdb {
    local host=$1
    echo "installing pfamfullseqdb on $host"
    ssh $host "mkdir -p /data/pfamfullseqdb"
    path_pfamfullseqdb="/data/pfamfullseqdb/pfamfullseqdb_pfam${version}"
    if [ ! -d "$path_pfamfullseqdb" ]; then
        echo "Error: $path_pfamfullseqdb does not exist."
        exit 1
    fi
    rsync -avz --progress $path_pfamfullseqdb/ $host:$path_pfamfullseqdb/
}

function install_pfam {
    local host=$1
    echo "installing pfam on $host"
    ssh $host "mkdir -p /data/pfam"
    path_pfam="/data/pfam/pfam${version}.0"
    if [ ! -d "$path_pfam" ]; then
        echo "Error: $path_pfam does not exist."
        exit 1
    fi  
    rsync -avz --progress $path_pfam/ $host:$path_pfam/
}

install_pfamfullseqdb_on_remote() {
    local host=$1
    install_pfamfullseqdb $host
    install_pfam $host
    $rundir/run_script_on_remote.sh -s $rundir/update_pfamfullseqdb_symlink.sh -g "$version" $host
}

for host in "${hostlist[@]}"; do
    install_pfamfullseqdb_on_remote $host
done    