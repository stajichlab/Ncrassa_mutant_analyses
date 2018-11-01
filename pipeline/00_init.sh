#!/bin/bash
#SBATCH --nodes 1 --ntasks 2 --mem 8G -p short --out logs/init.log

# EXPECTED VARIABLES
GENOMEFOLDER=genome
CONFIG=config.txt

if [ -f $CONFIG ]; then
     source $CONFIG
fi

module load bwa/0.7.17
module load samtools/1.8
module load picard
mkdir -p logs
if [ ! -e $GENOMENAME.fasta ]; then
	ln -s $GENOMEFOLDER/$GENOMEFASTA $GENOMENAME.fasta
fi
if [ ! -f $GENOMEFOLDER/$GENOMENAME.sa ]; then
    bwa index -p $GENOMEFOLDER/$GENOMENAME $GENOMEFOLDER/$GENOMEFASTA
fi

if [ ! -e $GENOMEFOLDER/$GENOMENAME.fai ]; then
	samtools faidx $GENOMEFOLDER/$GENOMENAME.fasta
fi


if [ ! -e $GENOMEFOLDER/$GENOMENAME.dict ]; then
    picard CreateSequenceDictionary R=$GENOMEFOLDER/$GENOMEFASTA O=$GENOMEFOLDER/$GENOMENAME.dict SPECIES=Candida_lusitaniae TRUNCATE_NAMES_AT_WHITESPACE=true
fi
