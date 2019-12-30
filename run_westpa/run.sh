#!/bin/bash
#
# run.sh
#
# Run the weighted ensemble simulation. Make sure you ran init.sh first!
#

source env.sh

# Make sure the server file is new!
#if [ -e $SERVER_INFO ] ; then
#  rm $SERVER_INFO 
#fi


# Start the zmq server.
$WEST_ROOT/bin/w_run \
    --debug \
    --work-manager=zmq \
    --n-workers=1 \
    --zmq-mode=master \
    --zmq-write-host-info=$SERVER_INFO \
    --zmq-comm-mode=tcp \
    --zmq-master-heartbeat 1000 \
    --zmq-worker-heartbeat 1000 \
    --zmq-timeout-factor 50 \
    &> ${LOGDIR}/west.log-$SLURM_JOBID &

# Wait on ZMQ server info file up to one minute
for ((n=0; n<60; n++)); do
  if [ -e $SERVER_INFO ] ; then
    echo "Server info file detected: $SERVER_INFO"
    cat $SERVER_INFO
    break
  fi
  sleep 1
done

# Exit if ZMQ server info file doesn't appear in one minute
if ! [ -e $SERVER_INFO ] ; then
  echo 'Server failed to start'
  exit 1
fi

# Run node.sh on each of the nodes.
#
# The --debug flag is not necessary, and it will make your log files very
# large.  However, it is useful for starting new simulations, when you are
# more likely to encounter errors.
#
# The ZMQ master and workers communicate with each other at an interval called
# the "heartbeat".  If you experience errors that state "no contact from worker ...",
# You may need to increase these values.
srun -n $SLURM_NNODES $WEST_SIM_ROOT/westpa_scripts/node.sh \
    --debug \
    --work-manager=zmq \
    --n-workers=11 \
    --zmq-mode=node \
    --zmq-read-host-info=$SERVER_INFO \
    --zmq-comm-mode=tcp \
    --zmq-master-heartbeat 1000 \
    --zmq-worker-heartbeat 1000 \
    --zmq-timeout-factor 50 &

wait  
