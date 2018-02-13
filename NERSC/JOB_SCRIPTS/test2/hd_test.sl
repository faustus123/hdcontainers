#!/bin/bash -l

#SBATCH -J GLUEX_RECON_031034_002
#SBATCH --volume="/global/project/projectdirs/m2828/GLUEX/031034_002:/data"
#SBATCH --image=docker:jeffersonlab/hdrecon:latest
#SBATCH --nodes=1           # Use 1 node
#SBATCH --time=6:00:00      # Set 2.5hr time limit
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=272
#SBATCH --qos=regular       # Submit to the regular 'partition'
#SBATCH -C knl              # Use Haswell nodes
#SBATCH -L project

# Run a single job on a single node. (We don't need to use srun here
# since we're not running on multiple nodes).

shifter /data/run_job.sh


