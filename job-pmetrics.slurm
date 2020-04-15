#!/bin/bash

#SBATCH --job-name=Pmetrics-test
#SBATCH --account=nn9736k
#SBATCH --time=1-10:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4 
##SBATCH --ntasks=40
#SBATCH --mem-per-cpu=8G
##SBATCH --mem=0

## Recommended safety settings:                                                                                              
set -o errexit # Make bash exit on any error                                                                                 
## do not set nounset as this fail fail during conda activate
##set -o nounset # Treat unset variables as errors   

#########################################################


## Setup environment
module load Anaconda2/2019.03
source /cluster/software/Anaconda2/2019.03/etc/profile.d/conda.sh
conda activate /cluster/work/support/sabryr/conda/pmetrics/R-3.5.1/
export LD_LIBRARY_PATH=/cluster/work/support/sabryr/conda/pmetrics/R-3.5.1//lib


##Run pmetrics
#./pmetrics.sh 9997 120 inputs/data2.csv inputs/model2.txt
./pmetrics.sh 99 120 inputs/data2.csv inputs/model2.txt
