library(gdsfmt)
library(SNPRelate)
gdsfile = "snps_selected.gds"
vcf.fn <- "NcrassaOR74A.Run1.selected.SNP.vcf.gz"
if(!file.exists(gdsfile)){
	snpgdsVCF2GDS(vcf.fn, gdsfile,method="biallelic.only")
}
snpgdsSummary(gdsfile)

genofile <- snpgdsOpen(gdsfile)
pca <- snpgdsPCA(genofile,num.thread=2,autosome.only=FALSE)
pc.percent <- pca$varprop*100

pca$sample.id

head(round(pc.percent, 2))
pdf("PCA_snp_plots.pdf")
tab <- data.frame(sample.id = pca$sample.id,
                 # pop = pheno$MinimalMediaGrowth,
                  EV1=pca$eigenvect[,1], # PCA vector 1
                  EV2=pca$eigenvect[,2], # PCA vector 2
		  stringsAsFactors=FALSE)

plot(tab$EV2, tab$EV1,
     #, col=as.integer(tab$pop),
xlab="eigenvector 2", ylab="eigenvector 1", main="PCA SNP plot")

#,col=1:nlevels(tab$pop))
