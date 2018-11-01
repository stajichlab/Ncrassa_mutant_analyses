#!/bin/sh
#SBATCH --nodes=1
#SBATCH --ntasks=2
#SBATCH  --mem=32G
#SBATCH  --time=36:00:00
#SBATCH --job-name realign
#SBATCH --output=logs/realign.%a.log

module load java/8
module load gatk/3.7
module load picard
module load samtools/1.8

RGCENTER=MyCenter
RGPLATFORM=Illumina

CONFIG=config.txt

if [ -f $CONFIG ]; then
    source $CONFIG
fi

MEM=32g
GENOMEIDX=$GENOMEFOLDER/$GENOMENAME
KNOWNSITES=
if [ ! -f $GENOMEFOLDER/$GENOMENAME.dict ]; then
    picard CreateSequenceDictionary R=$GENOMEIDX O=$GENOMEFOLDER/$GENOMENAME.dict SPECIES=Neurospora_crassa TRUNCATE_NAMES_AT_WHITESPACE=true
fi

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

IFS=,
tail -n +2 $SAMPLESINFO | sed -n ${N}p | while read SRA STRAIN BIOSAMPLE BIOPROJECT READ1 READ2 PAIRED
do
    if [ ! -e $ALNFOLDER/$SRA.cram ]; then
	if [ ! -e $ALNFOLDER/$SRA.realign.bam ]; then
	    if [ ! -e $ALNFOLDER/$SRA.DD.bam ]; then
		echo "Missing $ALNFOLDER/$SRA.DD.bam - re-run step 1 with $N"
		exit
	    fi
	    if [ ! -e $ALNFOLDER/$SRA.DD.bai ]; then
 		picard BuildBamIndex I=$ALNFOLDER/$SRA.DD.bam TMP_DIR=/scratch
	    fi

	    if [ ! -e $ALNFOLDER/$SRA.intervals ]; then 
		java -Xmx${MEM} -jar $GATK \
   		    -T RealignerTargetCreator \
   		    -R $GENOMEIDX.fasta \
   		    -I $ALNFOLDER/$SRA.DD.bam \
   		    -o $ALNFOLDER/$SRA.intervals
	    fi
    
	    if [ ! -e $ALNFOLDER/$SRA.realign.bam ]; then
		java -Xmx$MEM -jar $GATK \
   		    -T IndelRealigner \
   		    -R $GENOMEIDX.fasta \
   		    -I $ALNFOLDER/$SRA.DD.bam \
   		    -targetIntervals $ALNFOLDER/$SRA.intervals \
   		    -o $ALNFOLDER/$SRA.realign.bam
	    fi
	fi
	if [ -e $ALNFOLDER/$SRA.realign.bam ]; then
		samtools view -T $GENOMEIDX.fasta --threads $CPU -O CRAM -o $ALNFOLDER/$SRA.cram $ALNFOLDER/$SRA.realign.bam
		samtools index $ALNFOLDER/$SRA.cram
	fi

	if [ -e $ALNFOLDER/$SRA.cram ]; then
		unlink $ALNFOLDER/$SRA.realign.bam
		unlink $ALNFOLDER/$SRA.realign.bai
		unlink $ALNFOLDER/$SRA.DD.bam
		unlink $ALNFOLDER/$SRA.DD.bai
	fi
    fi
    
    if [ ! -e $KNOWNSITES]; then
	if [ ! -f $ALNFOLDER/$SRA.recal.grp ]; then
 	    java -Xmx$MEM -jar $GATK \
		-T BaseRecalibrator \
		-R $GENOMEIDX.fasta \
		-I $ALNFOLDER/$SRA.cram \
		--knownSites $KNOWNSITES \
		-o $ALNFOLDER/$SRA.recal.grp
	fi
	if [ ! -f $ALNFOLDER/$SRA.recal.cram ]; then
 	    java -Xmx$MEM -jar $GATK \
		-T PrintReads \
		-R $GENOMEIDX.fasta \
		-I $ALNFOLDER/$SRA.cram \
		-BQSR $ALNFOLDER/$SRA.recal.grp \
		-o $ALNFOLDER/$SRA.recal.cram
	fi
    fi
done
