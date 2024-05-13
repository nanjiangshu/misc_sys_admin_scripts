#!/bin/bash
# update the symlink to the specified version of the pfamfullseqdb and the pfam databases
# the version of the pfamfullseqdb and pfam databases should be the same

usage="
USAGE: $0 <version>

Example:
    $0 36
"

if [ -z "$1" ]; then
    echo "$usage"
    exit 1
fi  

version="$1"

function change_link {
    local dir=$1
    local src=$2
    local dst=$3
    if pushd "$dir" > /dev/null; then
        ln -sfn "$src" "$dst" && echo "Updated symlink $dst in $dir."
        popd > /dev/null
    else
        echo "Error: Unable to navigate to $dir."
        exit 1
    fi
}

change_link "/data/pfamfullseqdb" "pfamfullseqdb_pfam${version}" "pfamfullseqdb"
change_link "/data/pfam" "pfam${version}.0" "pfam"