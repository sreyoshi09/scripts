#!/bin/bash -x
#SBATCH -p gpu --gres=gpu:1 -N 1 -c 12 -t  120:0:0 -J feng_disp -o 'west_1.%j.out' -e 'west_1.%j.err'
source env.sh
srun hostname
env
df -h
cd $WEST_SIM_ROOT
./run.sh
