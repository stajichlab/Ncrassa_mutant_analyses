#!/usr/bin/bash
#SBATCH --mem 2gb 

module load plink
plink --bcf ../vcf/NcrassaOR74A.Run1.selected.bcf --const-fid --allow-extra-chr  --vcf-idspace-to _ --keep-allele-order --make-bed --out NcrassaOR74A.Run1

#plink --bcf ../vcf/NcrassaOR74A.Run1.selected.bcf --const-fid --allow-extra-chr  --vcf-idspace-to _ --keep-allele-order --make-bed --geno 0.1 --out NcrassaOR74A.Run1.filt2
#plink --bcf ../vcf/NcrassaOR74A.Run1.selected.bcf --const-fid --allow-extra-chr  --vcf-idspace-to _ --keep-allele-order --make-bed --geno 0.1 --indep-pairwise 5kb 5 0.5 --out NcrassaOR74A.Run1.filt3

