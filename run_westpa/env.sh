#!/bin/bash -x
# This file defines where WEST and Gromacs can be found
# Modify to taste

# Set environment variables for Gromacs for convenience

export PATH=/home/ssur2/westpa_update/westpa_new/bin:$PATH
. /home/ssur2/westpa_update/westpa_new/etc/profile.d/conda.sh


source activate westpa-2017.10

source  /home/ssur2/gromacs-2016.3_gpu/bin/bin/GMXRC
export GMX=/home/ssur2/gromacs-2016.3_gpu/bin/bin/gmx


#source  /home/ssur2/bin/gromacs/bin/GMXRC
#export GMX=/home/ssur2/bin/gromacs/bin/gmx
export WEST_ROOT=/home/ssur2/westpa_update/westpa_new/envs/westpa-2017.10/westpa-2017.10
echo "$WEST_ROOT"
module load swig             
module load scons
module load boost/1.66.0/b3
module load openblas                                                                    
source /home/ssur2/loos-new/setup.sh



export SERVER_INFO=${WEST_SIM_ROOT}/server_info.json
export OPEN_BLAS_NUM_THREADS=1
# Inform WEST where to find Python and our other scripts where to find WEST

export WM_ZMQ_MASTER_HEARTBEAT=1000
export WM_ZMQ_WORKER_HEARTBEAT=1000
export WM_ZMQ_TIMEOUT_FACTOR=1000
if [[ -z "$WEST_ROOT" ]]; then
    echo "Must set environ variable WEST_ROOT"
    exit
fi

# Explicitly name our simulation root directory
if [[ -z "$WEST_SIM_ROOT" ]]; then
    export WEST_SIM_ROOT="$PWD"
fi
export LOGDIR=${WEST_SIM_ROOT}/job_logs
# Set simulation name
export SIM_NAME=$(basename $WEST_SIM_ROOT)
echo "simulation $SIM_NAME root is $WEST_SIM_ROOT"

#Setting variables for use in runseg.sh and get_pcoord.sh.

export TOP_LOC=$WEST_SIM_ROOT/gromacs_config/initial.top
export NDX_LOC=$WEST_SIM_ROOT/gromacs_config/index.ndx
export MDP_LOC=$WEST_SIM_ROOT/gromacs_config/npt_1.mdp
export TOP=initial.top
export NDX=index.ndx

export MDP=npt_1.mdp
