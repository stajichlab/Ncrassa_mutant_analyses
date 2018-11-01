#!/usr/bin/bash
# make sure log folder exists
mkdir -p logs

if [ ! -f genome/Neurospora_crassa_OR74A.v39.fasta ]; then
curl -o genome/Neurospora_crassa_OR74A.v39.fasta http://fungidb.org/common/downloads/Current_Release/NcrassaOR74A/fasta/data/FungiDB-39_NcrassaOR74A_Genome.fasta
fi
if [ ! -f genome/Neurospora_crassa_OR74A.v39.gff ]; then
curl -o genome/Neurospora_crassa_OR74A.v39.gff http://fungidb.org/common/downloads/Current_Release/NcrassaOR74A/gff/data/FungiDB-39_NcrassaOR74A.gff
fi
