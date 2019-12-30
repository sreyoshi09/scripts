#!/bin/bash
#
# node.sh
set -x

cd $SLURM_SUBMIT_DIR
source env.sh

# This would be a good place to load any necessary modules
module load boost/1.62.0/1
module load openblas/0.2.19/b1
source /home/ssur2/loos/setup.sh
export OPEN_BLAS_NUM_THREADS=1
# Each node will write to a separate log file.
SUFFIX=$(hostname | cut -d\. -f1)
LOG="$LOGDIR/west-$SUFFIX.log"
# This will be our local scratch space
export WORKDIR="${LOCAL}"

# This should already be empty.
#if [ -n "$(ls -A ${WORKDIR})" ]; then
#  rm -rf $WORKDIR/*
#fi

# Since these files do not change and we need to access them many times, copy
# them over to local scratch space.
#cp -r $WEST_ROOT/gromacs_config $WORKDIR/

# Run simulation
$WEST_ROOT/bin/w_run "$@" &> $LOG
