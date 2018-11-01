#!/usr/bin/bash

# This is setup for use of sratoolkit as installed on the UCR cluster and supports slurm arrayjobs for submitting analyses

#SBATCH --nodes 1 --ntasks 8 --mem 8gb --out logs/download.%a.log -J download

module load sratoolkit
module load aspera
# This file has a header so we will skip first line
METADATA=metadata/bioprojects.csv
OUTDIR=fastq
# For our system I use a local NCBI cache 
mkdir -p /scratch/$USER/cache

if [ ! $CPU ]; then
    CPU=1
fi

N=${SLURM_ARRAY_TASK_ID}

if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
	echo "Need a number via slurm array or on the cmdline"
	exit
    fi
fi

ASCP=$(which ascp)
IFS=,
tail -n +2 $METADATA | sed -n ${N}p | while read BioProject BioProjectId JGI_Project_Id BioSample Strain Name SRA_Run Provider
do
	echo "$SRA_Run"
	IFS=";" 
	read -r -a array <<< "$SRA_Run"
	for i in "${!array[@]}"
	do
		SRR=${array[$i]}
		echo "$SRR"
		if [ ! -f $OUTDIR/${SRR}_1.fastq.gz ]; then
			prefetch -a "$ASCP|$ASPERAKEY" -X 30000000 $SRR
			fastq-dump --gzip -O $OUTDIR --split-files $SRR
		fi
	done
done

