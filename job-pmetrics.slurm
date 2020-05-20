#!/bin/bash

#SBATCH --job-name=Pmetrics-test
#SBATCH --account=nn9736k
#SBATCH --time=1:10:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=4G

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
conda activate /cluster/work/support/sabryr/conda/pmetrics/R-3.6.0
export LD_LIBRARY_PATH=/cluster/work/support/sabryr/conda/pmetrics/R-3.6.0/lib:/cluster/software/imkl/2018.1.163-iimpi-2018a/mkl/lib/intel64_lin:$LD_LIBRARY_PATH

CYCLES=1
INDPTS=4
DATA_FILE="Examples/parallel/testmod.txt "
MODEL_FILE="Examples/parallel/testdata.csv"
PARALLEL="TRUE"
ODE="-4"
TOL="0.01"

##Run pmetrics
./pmetrics.sh $CYCLES $INDPTS $DATA_FILE $MODEL_FILE $PARALLEL $ODE $TOL
