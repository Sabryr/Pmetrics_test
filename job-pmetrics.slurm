#!/bin/bash

#SBATCH --job-name=Pmetrics-test
#SBATCH --account=xx
#SBATCH --time=4:10:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=3G

## Recommended safety settings:                                                                                              
# set -o errexit # Make bash exit on any error                                                                                 
## do not set nounset as this fail fail during conda activate
##set -o nounset # Treat unset variables as errors   

#########################################################


## Setup environment
conda deactivate &>/dev/null
conda deactivate &>/dev/null
module restore
export PATH=/node/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/cluster/bin  
module load Anaconda2/2019.03
source /cluster/software/Anaconda2/2019.03/etc/profile.d/conda.sh
conda activate /cluster/projects/nn9736k/conda/R-3.6.0
export LD_LIBRARY_PATH=/cluster/projects/nn9736k/conda/R-3.6.0/lib:/cluster/software/imkl/2018.1.163-iimpi-2018a/mkl/lib/intel64_lin:$LD_LIBRARY_PATH

CYCLES=9999
INDPTS=110
#MODEL_FILE="Examples/parallel/testmod.txt "
#DATA_FILE="Examples/parallel/testdata.csv"
MODEL_FILE="inputs/model.txt"
DATA_FILE="inputs/ex.csv"
PARALLEL="TRUE"
ODE="-4"
TOL="0.01"

##Run pmetrics
./pmetrics.sh $CYCLES $INDPTS $DATA_FILE $MODEL_FILE $PARALLEL $ODE $TOL
