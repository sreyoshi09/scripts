#!/bin/bash -x
#if [ -n "$SEG_DEBUG" ] ; then
#    set -x
#    env | sort
#fi

cd $WEST_SIM_ROOT

DIST=feng_fengdist_$$.dat

function cleanup() {
   rm -f $DIST
}

trap cleanup EXIT

# Get progress coordinate
ls -l $WEST_PCOORD_RETURN
/software/anaconda/4.4.0/bin/python prog_coord.py bstates/visual.psf $WEST_STRUCT_DATA_REF > $DIST
head -n 1 $DIST > $WEST_PCOORD_RETURN

ls -l $WEST_PCOORD_RETURN

if [ -n "$SEG_DEBUG" ] ; then
    head -v $WEST_PCOORD_RETURN
fi
