#!/bin/bash
echo $@
cd "$1"
ls -lhrt 
PM_RLIB="$2"
REPORTSCRIPT="$3"
echo Linux>time.txt
date +%s>>time.txt
./np_prep MacOSX < PMcontrol
echo 1 > extnum
echo go > go
/usr/bin/gfortran -mcmodel=medium -m64 -O3 -L${HPC_MKL_LIB} -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -o np_run $PM_RLIB/Pmetrics/compiledFortran/sNPeng.o npagdriv.f
./np_run < go
echo;echo Cleaning up....;echo
stty sane
mkdir inputs 
mkdir outputs 
mkdir wrkcopy  
mkdir etc  
echo data.csv >> NP_RF0001.TXT
if [ ! -f NP_RF0001.TXT ]; then error=true; else error=false; fi
if [ -f DEN* ]; then mv DEN* outputs; fi
if [ -f OUT0* ]; then mv OUT0* outputs; fi
if [ -f OUTT* ]; then mv OUTT* outputs; fi
if [ -f PRTB* ]; then mv PRTB* outputs; fi
if [ -f ILOG* ]; then mv ILOG* outputs; fi
if [ -f NP_RF* ]; then mv NP_RF* outputs; fi
if [ -f ERROR* ]; then mv ERROR* outputs; fi
mv instr.inx etc
mv log.txt outputs
mv PMcontrol etc
mv model.for etc/model.for
mv model.txt inputs/model.txt
mv XQZPJ*.ZMQ wrkcopy
mv extnum etc
mv npag*.* etc
rm CHMAX*.*
if [ -f FROM0001 ]; then mv FROM0001 inputs; fi
rm fort.*
rm go
mv np_prep* etc
mv np_run* etc
mv data.csv inputs
date +%s >> time.txt
mv time.txt outputs
if ! $error ; then 
echo Rscript $REPORTSCRIPT $1'/outputs' 'median' 'NPAG' TRUE
Rscript $REPORTSCRIPT $1'/outputs' 'median' 'NPAG' TRUE
echo "results are in"  $1'/outputs/NPAGreport.html' ; fi
mv npscript $1"/etc"
