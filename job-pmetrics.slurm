#!/bin/bash

#SBATCH --job-name=Pmetrics-test
#SBATCH --account=nn9736k
#SBATCH --time=1-10:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=8G

## Recommended safety settings:                                                                                              
# set -o errexit # Make bash exit on any error                                                                                 
## do not set nounset as this fail fail during conda activate
##set -o nounset # Treat unset variables as errors   

#########################################################


## Setup environment
conda deactivate &>/dev/null
module restore
module load Anaconda2/2019.03
source /cluster/software/Anaconda2/2019.03/etc/profile.d/conda.sh
conda activate /cluster/work/support/sabryr/conda/pmetrics/R-3.6.0
export LD_LIBRARY_PATH=/cluster/work/support/sabryr/conda/pmetrics/R-3.6.0/lib:/cluster/software/imkl/2018.1.163-iimpi-2018a/mkl/lib/intel64_lin:$LD_LIBRARY_PATH

export R_LIBS=/cluster/projects/nn9997k/sabryr/new_pmetrics/R

##Run pmetrics
#./pmetrics.sh 997 120 inputs/data2.csv inputs/model2.txt
./pmetrics.sh 997 108 propdata/data2.csv propdata/model2.txt
