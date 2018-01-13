#!/bin/bash -l

#SBATCH -J GLUEX_TEST
#SBATCH --image=docker:jeffersonlab/hdrecon:2.20.1
#SBATCH -N 1         # Use 1 node
#SBATCH -t 2:30:00   # Set 2.5hr time limit
#SBATCH -p regular   # Submit to the regular 'partition'
#SBATCH -C haswell   # Use Haswell nodes
#SBATCH --volume="/project/projectdirs/m2828:/data"


# Run a single job on a single node. (We don't need to use srun here
# since we're not running on multiple nodes). The job can use all
# cores on the node.
shifter hd_root --config=jana_recon.config hd_rawdata_031034_002.evio

