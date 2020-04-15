#!/bin/bash
#2020-02-14 Sabryr
#Two argments mycycles and myindpts
mycycles=100 #9997
myindpts=108 #108

if [ "$#" -eq 4 ]
then
	mycycles=$1 #9997
	myindpts=$2 #108
	model_file=$3  #$INPUT_DIR"/dataset.csv" 
	dataset_file=$4 #$INPUT_DIR"/model.txt"
	model_file_nm=$(echo $model_file | awk -F "/" '{print $NF}')
	echo $model_file
	echo $dataset_file
	
	#echo ${#model_file_nm}
	#if [ ${#model_file_nm} -ge 8 ]
	#then
	#	echo "model_file name length should not exceed 8, your file name  "	
	#	echo model_file | awk -F "/" '{print $NF}'
	#	exit 1
	#fi
else
	echo "Need four arguments"
	echo "1. mycycles"
	echo "2. myindpts"
	echo "3. Full path to dataset"
	echo "4. Full path to model file"
	exit 1
fi

echo "Processing"
#exit 1


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
echo $RSCRIPT $Pmetricstar $LOC $model_file $dataset_file $mycycles $myindpts
$RSCRIPT $LOC $model_file $dataset_file $mycycles $myindpts &>> $LOG

echo $RSCRIPT " -- done"
mv 1 $OUT_DIR
cd $OUT_DIR

echo "directory rename from 1 to $OUT_DIR -- done "

echo "Reports not created, as that step was skipped"
echo "To create reports issue the command"
echo $NPSCRIPT $OUT_DIR $R_LIBS $REPORTSCRIPT 
#$NPSCRIPT $OUT_DIR $R_LIBS $REPORTSCRIPT
echo "Done, output folder is $OUT_DIR"
stty sane

