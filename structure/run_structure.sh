#!/usr/bin/bash
#SBATCH --nodes 1 --ntasks 1 --mem 16gb --out structure.%a.log

K=${SLURM_ARRAY_TASK_ID}
structure.py -K $K --input=NcrassaOR74A.Run1 --output=NcrassaOR74A.Run1
