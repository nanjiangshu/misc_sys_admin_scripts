#!/bin/bash 


rundir=`dirname $0`
rundir=`readlink -f $rundir`
cd $rundir
tmpdir=build.$$
mkdir -p $tmpdir
cd $tmpdir

module add openmpi

INSTALL_BASE_DIR=$rundir
cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=${INSTALL_BASE_DIR} $rundir
make
make install
rm -rf $tmpdir
