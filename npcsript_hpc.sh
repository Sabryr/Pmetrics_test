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
cp ${PM_RLIB}"/Pmetrics/code/NPeng_120.f" .
ls -lh ${PM_RLIB}"/Pmetrics/code/NPeng_120.f"
ls -lh 
export HPC_MKL_LIB=/cluster/software/imkl/2018.1.163-iimpi-2018a/mkl/lib/intel64
/usr/bin/gfortran -mcmodel=medium -m64 -O3 -w -fopenmp -fmax-stack-var-size=32768  -L${HPC_MKL_LIB} -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -o pNPeng.o -c 'NPeng_120.f'
/usr/bin/gfortran -mcmodel=medium -m64 -O3 -w -fopenmp -fmax-stack-var-size=32768  -L${HPC_MKL_LIB} -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -o np_run pNPeng.o npagdriv.f
#/usr/bin/gfortran -mcmodel=medium -m64 -O3 -w -fopenmp -fmax-stack-var-size=32768  -L${HPC_MKL_LIB} -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -o np_run $PM_RLIB/Pmetrics/compiledFortran/sNPeng.o npagdriv.f
exit 1
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
echo "BLOCK " Rscript $REPORTSCRIPT $1'/outputs' 'median' 'NPAG' TRUE
#Rscript $REPORTSCRIPT $1'/outputs' 'median' 'NPAG' TRUE
#echo "results are in"  $1'/outputs/NPAGreport.html' ; fi
mv npscript $1"/etc"
