#!/usr/bin/bash 

#SBATCH --nodes 1 --ntasks 8 --mem 64G --out logs/aln.%a.log --time 2:00:00 -p short

#This script takes a reference genome and a tab delimited sample list of: sample name\tsample_reads_1.fq\tsample_reads_2.fq.
# For each line defined by the number in an array job, this script will align set of reads to a reference genome using bwa mem.
#After, it uses picard to add read groups and mark duplicates. 

RGCENTER=UCR
RGPLATFORM=Illumina
CONFIG=config.txt
BWA=bwa
if [ -f $CONFIG ]; then
    source $CONFIG
fi

TEMPDIR=/scratch

module load bwa/0.7.17
module load picard
module load samtools/1.8
module unload java
module load java/8
export JAVA_OPTS="-Xmx64G"
CPU=1

hostname
mkdir -p $ALNFOLDER

if [ $SLURM_CPUS_ON_NODE ]; then
 CPU=$SLURM_CPUS_ON_NODE
fi
N=${SLURM_ARRAY_TASK_ID}

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
GENOMEIDX=$GENOMEFOLDER/$GENOMENAME
echo "$GENOMEIDX"
IFS=,
tail -n +2 $SAMPLESINFO | sed -n ${N}p | while read SRA STRAIN BIOSAMPLE BIOPROJECT READ1 READ2 PAIRED
do
    READ1=$FASTQFOLDER/$READ1
    READ2=$FASTQFOLDER/$READ2
    PU=$BIOSAMPLE
    if [ -z $CTR ]; then
	CTR=$RGCENTER
    fi
    echo "paired='$PAIRED' READ2=$READ2"
    [ "$PAIRED" == "Y" ] && echo "Is Paired"
    [ "$PAIRED" == "N" ] && echo "Is Not Paired"
    echo "SAMPLE=$SRA READ1=$READ1 READ2=$READ2 center=$CTR paired='$PAIRED'"
    if [ ! -f $ALNFOLDER/$SRA.DD.bam ]  || [ ! -s $ALNFOLDER/$SRA.DD.bam ]; then
        if [ ! -f $ALNFOLDER/$SRA.sort.bam ]; then
	    if [ "$PAIRED" = "Y" ]; then
		echo "PE: $BWA mem -t -M $CPU $GENOMEIDX $READ1 $READ2"
		$BWA mem -M -t $CPU $GENOMEIDX $READ1 $READ2 | samtools sort -T /scratch/$SRA --reference $GENOMEIDX.fasta -@ $CPU -o $ALNFOLDER/$SRA.sort.bam -
	    else
		echo "SE: $BWA mem -t -M $CPU $GENOMEIDX $READ1"
		$BWA mem -M -t $CPU $GENOMEIDX $READ1 | samtools sort -T /scratch/$SRA --reference $GENOMEIDX.fasta -@ $CPU -o $ALNFOLDER/$SRA.sort.bam -
		fi
        fi
	if [ ! -f $ALNFOLDER/$SRA.RG.bam ]; then
	 	picard AddOrReplaceReadGroups RGID=$SRA RGSM=$STRAIN RGLB=$SRA RGPL=$RGPLATFORM RGPU=$PU RGCN=$CTR \
		 I=$ALNFOLDER/$SRA.sort.bam O=$ALNFOLDER/$SRA.RG.bam VALIDATION_STRINGENCY=SILENT
	fi
        picard MarkDuplicates I=$ALNFOLDER/$SRA.RG.bam O=$ALNFOLDER/$SRA.DD.bam \
            METRICS_FILE=$ALNFOLDER/$SRA.dedup.metrics VALIDATION_STRINGENCY=SILENT CREATE_INDEX=true
	if [ -e $ALNFOLDER/$SRA.DD.bam ]; then
		unlink $ALNFOLDER/$SRA.RG.bam 
		unlink $ALNFOLDER/$SRA.sort.bam
	fi
    fi
done
