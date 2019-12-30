#!/bin/bash -x

if [ -n "$SEG_DEBUG" ] ; then
    set -x
    env | sort
fi

cd $WEST_SIM_ROOT

mkdir -p $(dirname $WEST_ISTATE_DATA_REF)

# Generate random displacement from basis state
cp $WEST_BSTATE_DATA_REF $WEST_ISTATE_DATA_REF

#frame2pdb bstates/unbound/feng_1_popc.psf /run/media/sreyoshi/Roosha/lab/new/feng_1_popc/sim1/center_1.dcd $(((RANDOM % 600)+1)) > test.pdb
#gmx editconf -f test.pdb -o $WEST_ISTATE_DATA_REF
