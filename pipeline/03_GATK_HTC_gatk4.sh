#!/usr/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH  --mem 16gb
#SBATCH  --time=48:00:00
#SBATCH --job-name HTC
#SBATCH --output=logs/HTC.%a.log

module load java/8
module load gatk/4
module load picard
module load samtools/1.8
module load tabix
CONFIG=config.txt

if [ -f $CONFIG ]; then
    source $CONFIG
fi

hostname

MEM=16g
GENOMEIDX=$GENOMEFOLDER/$GENOMENAME

CPU=$SLURM_CPUS_ON_NODE

if [ ! $CPU ]; then 
 CPU=1
fi

N=${SLURM_ARRAY_TASK_ID}

if [ -z $N ]; then
 N=$1
 if [ -z $N ]; then
	 echo "Need a number via slurm --array or cmdline"
 	exit
 fi
fi

mkdir -p $VARIANTFOLDER
IFS=,
tail -n +2 $METADATA | sed -n ${N}p | while read BioProject BioProjectId JGI_Project_Id BioSample Strain Name SRA_Run Provider
do
	#IN="--input $ALNFOLDER/$SRA_Run.cram"
	#IN=$(echo $IN | perl -p -e "s/;/.cram --input $ALNFOLDER\//g")

	IFS=";"

	read -r -a array <<< "$SRA_Run"
	for i in "${!array[@]}"
	do
	    if [ ! -f $ALNFOLDER/${array[$i]}.cram.crai ]; then
		samtools index $ALNFOLDER/${array[$i]}.cram
	    fi
	    IN+="--input $ALNFOLDER/${array[$i]}.cram "
	done
	if [ ! -e $VARIANTFOLDER/$Strain.g.vcf.gz ]; then
	    if [ ! -e $VARIANTFOLDER/$Strain.g.vcf ]; then
		CMD="gatk --java-options -Xmx${MEM} HaplotypeCaller -ERC GVCF -ploidy 1 ${IN} -R $GENOMEIDX.fasta -O $VARIANTFOLDER/$Strain.g.vcf --native-pair-hmm-threads $CPU"
		echo $CMD
		eval $CMD
	    fi
	    bgzip $VARIANTFOLDER/$Strain.g.vcf
	    tabix $VARIANTFOLDER/$Strain.g.vcf.gz
	fi

done
