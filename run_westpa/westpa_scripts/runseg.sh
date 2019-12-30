#!/bin/bash -x
source env.sh
if [ -n "$SEG_DEBUG" ] ; then
    set -x
    env | sort
fi

cd $WEST_SIM_ROOT

# Set up the run
mkdir -pv $WEST_CURRENT_SEG_DATA_REF
cd $WEST_CURRENT_SEG_DATA_REF

if [[ "$USE_LOCAL_SCRATCH" == "1" ]] ; then
    # make scratch directory
    WORKDIR=$SCRATCHROOT/$WEST_CURRENT_SEG_DATA_REF
    $SWROOT/bin/mkdir -pv $WORKDIR || exit 1
    cd $WORKDIR || exit 1
    STAGEIN="$SWROOT/bin/cp -avL"
else
    STAGEIN="$SWROOT/bin/ln -sv"
fi


function cleanup() {
    # Clean up.  Copy back what we want, and remove the rest.
    # Also, remove our copied in parent references.  We don't need to keep that.
    $SWROOT/bin/rm -f none.xtc whole.xtc $REF parent.*
    if [[ "$USE_LOCAL_SCRATCH" == "1" ]] ; then
        $SWROOT/bin/cp *.{cpt,xtc,trr,edr,tpr,gro,log,xvg} $WEST_CURRENT_SEG_DATA_REF || exit 1
        cd $WEST_CURRENT_SEG_DATA_REF
        $SWROOT/bin/rm -Rf $WORKDIR
    else
        # Here, we're not using local scratch.  Remove some specific things, in that case.
        $SWROOT/bin/rm -f *.itp *.mdp *.ndx *.top *.trr *.log
    fi
}

# Regardless of the reason we exit, run the function cleanup.
trap cleanup EXIT

case $WEST_CURRENT_SEG_INITPOINT_TYPE in
    SEG_INITPOINT_CONTINUES)
        # A continuation from a prior segment
        # $WEST_PARENT_DATA_REF contains the reference to the
        # We'll use the checkpoint files, rather than energy files,
        # in this case.
        #   parent segment
        $STAGEIN $WEST_PARENT_DATA_REF/seg.gro ./parent.gro
        $STAGEIN $WEST_PARENT_DATA_REF/seg.cpt ./parent.cpt
        $STAGEIN $WEST_PARENT_DATA_REF/seg.gro ./parent_imaged.gro
        $STAGEIN $GMX_CFG/* . 
        $GMX grompp -f $MDP_LOC -c parent.gro -t parent.cpt -p $TOP_LOC \
          -o seg.tpr -po md_out.mdp -maxwarn 1

    ;;

    SEG_INITPOINT_NEWTRAJ)
        # Initiation of a new trajectory
        # In truth, there's very little difference between a new trajectory
        # and an old one, except we handle our istates a little differently
        # than a previous segment, and use the .edr file.  
        # For an explicit solvent simulation,
        # all trajectories are considered continuations.
        # We are also copying in the basis state as the imaged ref.
        # $WEST_PARENT_DATA_REF contains the reference to the
        #   appropriate basis or initial state
#        $STAGEIN $WEST_PARENT_DATA_REF.edr ./parent.edr
        $STAGEIN $WEST_PARENT_DATA_REF ./parent.gro
#        $STAGEIN $WEST_PARENT_DATA_REF.trr ./parent.trr
        $STAGEIN $WEST_PARENT_DATA_REF ./parent_imaged.gro
        $STAGEIN $GMX_CFG/* .
        $GMX grompp -f $MDP_LOC -c parent.gro -p $TOP_LOC \
           -o seg.tpr -po md_out.mdp -maxwarn 2
    ;;

    *)
        # This should never fire.
        echo "unknown init point type $WEST_CURRENT_SEG_INITPOINT_TYPE"
        exit 2
    ;;
esac

# Propagate segment
# It's easiest to set our OpenMP thread count manually here.

$GMX mdrun -s  seg.tpr -o seg.trr -c  seg.gro \
       -cpo seg.cpt -g seg.log -x  seg.xtc -nt 1 

subsetter -v2 -C 'segid == "POPC"' '-P' 'segid == "POPC"' --reimage zealous seg $WEST_SIM_ROOT/bstates/visual.psf seg.xtc

# Calculate progress coordinate
$WEST_PYTHON $WEST_SIM_ROOT/prog_coord.py $WEST_SIM_ROOT/bstates/visual.psf seg.dcd > dist.dat|| exit 1
cp dist.dat  $WEST_PCOORD_RETURN
rm seg.dcd seg.pdb
# Output coordinates.  While we can return coordinates, this is expensive (data size) for a system of this size
# and so by default, it is off for this system.  However, by modifying the variable COMMAND, the group
# which has its coordinates returned can be modified and reduce the cost, so it is sensible to leave it in.

#if [ ${WEST_COORD_RETURN} ]; then
#    COMMAND="0 \n"
#   if [ ${GMX} ]; then
#        echo -e $COMMAND |mpirun -n 1 $GMX editconf -label ' ' -f seg.tpr -o seg.pdb
#   fi
#   cat seg.pdb | grep 'ATOM'    \
#      | awk '{print $6, $7, $8}' > $WEST_COORD_RETURN
#fi

# Output log
if [ ${WEST_LOG_RETURN} ]; then
    cat seg.log \
      | awk '/Started mdrun/ {p=1}; p; /A V E R A G E S/ {p=0}' \
      > $WEST_LOG_RETURN
fi
