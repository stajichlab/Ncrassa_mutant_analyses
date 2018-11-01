#!/usr/bin/bash
#SBATCH -p batch --mem 8gb

module load BBMap
CONFIG=config.txt
if [ -f $CONFIG ]; then
    source $CONFIG
fi

if [ ! $N ]; then
 N=$1
 if [ ! $N ]; then
    echo "Need a number via slurm --array or cmdline"
    exit
 fi
fi

if [ ! $SAMPLESINFO ]; then
    echo "need to define \$SAMPLESINFO in $CONFIG file"
    exit
fi

IFS=,
FIXED=fixedreads
mkdir -p $FIXED
tail -n +2 $SAMPLESINFO | sed -n ${N}p | while read SRA STRAIN BIOSAMPLE BIOPROJECT READ1 READ2 PAIRED
do
    READ1=$FASTQFOLDER/$READ1
    READ2=$FASTQFOLDER/$READ2
    FIXREAD1=$FIXED/$READ1
    FIXREAD2=$FIXED/$READ2
    if [ "$PAIRED" = "Y" ]; then
	filterbyname.sh in=$READ1 in2=$READ2 out=$FIXREAD1 out2=$FIXREAD2 tossbrokenreads=t
    else 
	filterbyname.sh in=$READ1 out=$FIXREAD1 tossbrokenreads=t
    fi	
    echo "# to replace fixed reads with original run"
    echo "mv $FIXREAD1 $READ1"
    [ "$PAIRED" == "Y" ] echo "mv $FIXREAD2 $READ2" 
done
