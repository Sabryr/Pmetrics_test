#!/bin/bash
#2020-02-14 Sabryr
#Two argments mycycles and myindpts
VERSION="0.1"
mycycles=100 #9997
myindpts=108 #108

MODEL_FILE_NM="model.txt"
DATA_FILE_NM="dataset.csv"

ODE="-4"
TOL="0.01"

parallel="FALSE"
export HPC_MKL_LIB=/cluster/software/imkl/2018.1.163-iimpi-2018a/mkl/lib/intel64

LOC=$PWD
OUT_DIR=$LOC"/out_"$(date +"%Y%m%d_%H%M%S")
LOG=$LOC"/out_"$(date +"%Y%m%d_%H%M%S")".log"
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
   conda activate /cluster/work/support/sabryr/conda/pmetrics/R-3.6.0 && which R
   export LD_LIBRARY_PATH=/cluster/work/support/sabryr/conda/pmetrics/R-3.6.0/lib:/cluster/software/imkl/2018.1.163-iimpi-2018a/mkl/lib/intel64_lin:$LD_LIBRARY_PATH
   $LOC"/install.rscript"   
  else
    echo "Pmetrics HPC test version "$VERSION
  fi
exit 0 
fi


ls [1-999]* &> /dev/null

if [  $? -eq 0 ]
then
        echo "Current directory contain runs from Pmetrics, that did not use the script for HPC"
        echo " --  "
        ls | grep -E '^[[:digit:]]+'
        echo "Please remove them or use new location"
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
	model_file_nm=$(echo $model_file | awk -F "/" '{print $NF}')
        echo $model_file
	echo $dataset_file
elif  [ "$#" -eq 4 ]
then
	mycycles=$1 #9997
	myindpts=$2 #108
	model_file=$3  #$INPUT_DIR"/dataset.csv" 
	dataset_file=$4 #$INPUT_DIR"/model.txt"
	model_file_nm=$(echo $model_file | awk -F "/" '{print $NF}')
	echo $model_file
	echo $dataset_file
   
else
	echo "Need four arguments"
	echo "1. mycycles"
	echo "2. myindpts"
	echo "3. Full path to dataset"
	echo "4. Full path to model file"
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

echo $RSCRIPT $LOC $model_file $dataset_file $mycycles $myindpts $parallel $MODEL_FILE_NM $DATA_FILE_NM $ODE $TOL

which Rscript
echo $RSCRIPT
#$RSCRIPT $LOC $model_file $dataset_file $mycycles $myindpts $parallel &>> $LOG
$RSCRIPT $LOC $model_file $dataset_file $mycycles $myindpts $parallel $MODEL_FILE_NM $DATA_FILE_NM $ODE $TOL &>> $LOG

echo $RSCRIPT " -- done"
mv 1 $OUT_DIR
cd $OUT_DIR

echo "directory rename from 1 to $OUT_DIR -- done "

echo $NPSCRIPT $OUT_DIR $R_LIBS $REPORTSCRIPT $MODEL_FILE_NM $DATA_FILE_NM  
echo "" &>> $LOG
echo "-----------"$NPSCRIPT"-------------" &>> $LOG
echo "" &>> $LOG
$NPSCRIPT $OUT_DIR $R_LIBS $REPORTSCRIPT $MODEL_FILE_NM $DATA_FILE_NM  $model_file $dataset_file&>> $LOG
echo "Done, output folder is $OUT_DIR"
echo "HTML report in "$OUT_DIR"/outputs/NPAGreport.html"
stty sane
