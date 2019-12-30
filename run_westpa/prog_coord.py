#!/usr/bin/env python
import loos
import loos.pyloos
import sys


psf = sys.argv[1]
string = sys.argv[2]
substring1 = "dcd"
substring2 = "gro"

if substring1 in string:
	source = loos.createSystem(psf)	
	traj = loos.pyloos.Trajectory(string,source)
	feng  = loos.selectAtoms(source,"segid == 'F22P' && resname != 'TAIL'")
	feng_individual = feng.splitByMolecule()
	for frame in traj:
    		box = source.periodicBox()    
    		CAB=0
    		cents= []
    		for m in feng_individual:
        		cents.append(m.centroid())
    		for i in range(len(feng_individual)-1):
        		for j in range(i+1,len(feng_individual)):
            			distance_between = cents[i].distance(cents[j])
            			Sij = 1/(1+(distance_between/10.0)**6)
            			CAB += Sij 
    		print CAB

if substring2 in string:
	source = loos.loadStructureWithCoords(psf,string)
	feng  = loos.selectAtoms(source,"resname == 'TAIL'")
        feng_individual = feng.splitByResidue()
	box = source.periodicBox()
        CAB=0
        cents= []
#	print len(feng_individual)
        for m in feng_individual:
        	cents.append(m.centroid())
        for i in range(len(feng_individual)-1):
                for j in range(i+1,len(feng_individual)):
	                distance_between = cents[i].distance(cents[j])
                        Sij = 1/(1+(distance_between/10.0)**6)
                        CAB += Sij
	print CAB
