#!/bin/bash
#2020-03-29 Sabryr
#This is the main batch script and the only one meant to be called directly.
#This script has hard coded paths for the saga compute cluster
#Script needs 7 arguments
# 1. Number of cycles
# 2. Numper of indpts
# 3. Full path to dataset
# 4. Full path	to model file
# 5. Parrallel TRUE/FALSE
# 6. ode value 
# 7. tol value
# The Pmetrics manual found in the following link provides details of these
# http://www.lapk.org/pmetrics.php 


VERSION="0.2"
CDATE=$(date +"%Y%m%d_%H%M%S")

LOCK_FILE="NA"

mycycles=100 #9997
myindpts=108 #108

MODEL_FILE_NM="modelX.txt"
DATA_FILE_NM="dataY.csv"

ODE="-4"
TOL="0.01"

parallel="FALSE"

#This is a hardcoded path for SAGA, should be fed in in the generic version
export HPC_MKL_LIB=/cluster/software/imkl/2018.1.163-iimpi-2018a/mkl/lib/intel64

LOC=$PWD
OUT_DIR=$LOC"/out_"$CDATE
LOG=$LOC"/out_"$CDATE".log"
echo "LOG "$LOG
touch $LOG
FCONF=$LOC"/FortConfig.txt"
RSCRIPT=$LOC"/pmetrics.rscript"
export R_LIBS=$LOC"/R"
mkdir $R_LIBS &> /dev/null
NPSCRIPT=$LOC"/npcsript_hpc.sh"
REPORTSCRIPT=$LOC"/pmreport.rscript"

touch $R_LIBS"/test"
PMETRICS_R=$R_LIBS"/Pmetrics"

if [ "$#" -eq 1 ]
then
  INP=$(echo $1 | tr a-z A-Z)
  if [[ "$INP" =~ "V"  ]] || [[ "$INP" =~ "VERSION"  ]]
  then  
     echo "Pmetrics HPC test version "$VERSION
  elif [[ "$INP" =~ "INSTALL" ]]
  then
   module restore
   conda deactivate &>/dev/null
   conda deactivate &>/dev/null
   export PATH=/node/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/cluster/bin
   source /cluster/software/Anaconda2/2019.03/etc/profile.d/conda.sh
   conda activate /cluster/projects/nn9736k/conda/R-3.6.0 && which R
   export LD_LIBRARY_PATH=/cluster/projects/nn9736k/conda/R-3.6.0/lib:/cluster/software/imkl/2018.1.163-iimpi-2018a/mkl/lib/intel64_lin:$LD_LIBRARY_PATH
   $LOC"/install.rscript"   
  else
    echo "Pmetrics HPC test version "$VERSION
  fi
exit 0 
fi

ls LOCK.* &> /dev/null

if [ $? -eq 0 ]
then
 echo "------------------"
 echo "There is already on going processing in the current location, please wait and try when that process has finished initializing"
 echo "------------------"
 cat LOCK.*
 echo "------------------"
 exit 1
else
  LOCK_FILE="LOCK."$BASHPID
  echo "Date: " $(date) > ${LOCK_FILE}
  echo "Started by: " $(echo $USER) >> ${LOCK_FILE}
  echo "lock file " ${LOCK_FILE}
  
fi

ls [1-999]* &> /dev/null

if [  $? -eq 0 ]
then
        echo "Current directory contain runs from Pmetrics, that did not use the script for HPC"
        echo " --  "
        ls | grep -E '^[[:digit:]]+'
        echo "Please remove them or use new location"
        rm ${LOCK_FILE} &> /dev/null
        sleep 2
        exit 1
fi


if [ -d "$PMETRICS_R" ]; then
   echo "PMtrics R libraries found in "$PMETRICS_R
else
   echo "PMtrics R libraries not found in expected location "$PMETRICS_R
   echo "Please install that from a login node first"
   echo "Command to to use:"
   echo "./pmetrics.sh INSTALL"
   exit 1
fi

if [ "$#" -eq 7 ]
then
	mycycles=$1 #9997
	myindpts=$2 #108
	model_file=$3  #$INPUT_DIR"/dataset.csv" 
	dataset_file=$4 #$INPUT_DIR"/model.txt"
        parallel=$5
        ODE="$6"
        TOL="$7"
	MODEL_FILE_NM=$(echo $model_file | awk -F "/" '{print $NF}')
        DATA_FILE_NM=$(echo $dataset_file | awk -F "/" '{print $NF}')
        echo $model_file
	echo $dataset_file
elif  [ "$#" -eq 4 ]
then
	mycycles=$1 #9997
	myindpts=$2 #108
	model_file=$3   
	dataset_file=$4
	MODEL_FILE_NM=$(echo $model_file | awk -F "/" '{print $NF}')
        DATA_FILE_NM=$(echo $dataset_file | awk -F "/" '{print $NF}')
        echo $model_file
	echo $dataset_file
   
else
	echo "Need 7 arguments"
	echo "1. Number of cycles"
	echo "2. Numper of indpts"
	echo "3. Full path to dataset"
	echo "4. Full path 	to model file"
	echo "5. Parrallel TRUE/FALSE"
	echo "6. ode value "
	echo "7. tol value"
	exit 1
fi

echo "Processing"

if [ $? -eq 0 ]
then
	echo "R packages will be installed to "$R_LIBS
	sleep 2
else
	echo "$R_LIBS not found"
fi

echo $LOC
echo $LOG
echo $OUT_DIR
echo $FCONF

echo $(date) > $LOG

#ls Pmetrics_*.tar.gz &> /dev/null

#if [ $? -eq 0 ]
#then
#  Pmetricstar=$(ls $PWD/Pmetrics_*.tar.gz)
#  echo "found "$Pmetricstar
#else
#  echo "Pmetrics tar not found in current directory "$PWD
#  echo "you may donwload Pmetrics_1.5.1.tar.gz using the link"
#  echo " wget http://www.lapk.org/software/Pmetrics/Repos/_gsdata_/_saved_/src/contrib/Pmetrics_1.5.1.tar.gz" 
#fi

mkdir -p $HOME/.config/Pmetrics &> /dev/null
cp $FCONF $HOME/.config/Pmetrics/

echo "------------------------------"


which Rscript
echo $RSCRIPT
echo $RSCRIPT $LOC $model_file $dataset_file $mycycles $myindpts $parallel $MODEL_FILE_NM $DATA_FILE_NM $ODE $TOL
$RSCRIPT $LOC $model_file $dataset_file $mycycles $myindpts $parallel $MODEL_FILE_NM $DATA_FILE_NM $ODE $TOL &>> $LOG


echo $RSCRIPT " -- done"
mv 1 $OUT_DIR
if [ $? -eq 0 ]
then
  echo "directory rename from 1 to $OUT_DIR -- done " 
else
 echo "directory rename from 1 to $OUT_DIR -- Failed "
 rm ${LOCK_FILE} &> /dev/null
 exit 1
fi

rm ${LOCK_FILE} &> /dev/null
cd $OUT_DIR

echo $NPSCRIPT $OUT_DIR $R_LIBS $REPORTSCRIPT $MODEL_FILE_NM $DATA_FILE_NM  $model_file $dataset_file 
echo "" &>> $LOG
echo "-----------"$NPSCRIPT"-------------" &>> $LOG
echo "" &>> $LOG

$NPSCRIPT $OUT_DIR $R_LIBS $REPORTSCRIPT $MODEL_FILE_NM $DATA_FILE_NM  $model_file $dataset_file &>> $LOG
echo "Done, output folder is $OUT_DIR"
echo "HTML report in "$OUT_DIR"/outputs/NPAGreport.html"
#stty sane
