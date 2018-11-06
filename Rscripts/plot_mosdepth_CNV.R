library(ggplot2)
library(RColorBrewer)
colors1 <- colorRampPalette(brewer.pal(8, "RdYlBu"))
manualColors = c("dodgerblue2","red1","grey20")

bedwindows = read.table("coverage/mosdepth.10000bp.gg.tab.gz",header=F)
colnames(bedwindows) = c("Chr","Start","End","Depth","Group","Strain")
#bedwindows = subset(bedwindows,bedwindows$Chr != "MT_CBS_6936") # drop MT for this

samples <- read.csv("samples.csv",header=T)
bedwindows$CHR <- strtoi(sub("CM00([0-9]+)","\\1",bedwindows$Chr,perl=TRUE))
bedwindows$CHR <- bedwindows$CHR - 2235

chrlist = 1:7
d=bedwindows[bedwindows$CHR %in% chrlist, ]
d <- d[order(d$CHR, d$Start), ]
d$index = rep.int(seq_along(unique(d$CHR)), times = tapply(d$Start,d$CHR,length)) 

d$pos=NA

nchr = length(unique(chrlist))
lastbase=0
ticks = NULL
minor = vector(,8)

for (i in 1:nchr ) {
    if (i ==1) {
        d[d$index==i, ]$pos = d[d$index==i, ]$Start
    } else {
        ## chromosome position maybe not start at 1, eg. 9999. So gaps may be produced. 
        lastbase = lastbase + max(d[d$index==(i-1),"Start"])
	      minor[i] = lastbase
        d[d$index == i,"Start"] =
             d[d$index == i,"Start"]-min(d[d$index==i,"Start"]) +1
        d[d$index == i,"End"] = lastbase
        d[d$index == i, "pos"] = d[d$index == i,"Start"] + lastbase
    }
}
ticks <-tapply(d$pos,d$index,quantile,probs=0.5)
ticks
minorB <- tapply(d$End,d$index,max,probs=0.5)
minorB
minor
xmax = ceiling(max(d$pos) * 1.03)
xmin = floor(max(d$pos) * -0.03)

#pdffile="plots/Genomewide_cov_by_10kb_win_mosdepth.pdf"
#pdf(pngfile,width=30)
#Title="Depth of sequence coverage - All Strains"
#p <- ggplot(d,
#            aes(x=pos,y=Depth,color=factor(CHR))) +
#	          geom_vline(mapping=NULL, xintercept=minorB,alpha=0.5,size=0.1,colour='grey15')	+
#            scale_colour_brewer(palette = "Set2") +
#            geom_point(alpha=0.9,size=0.1,shape=16) +
#            labs(title=Title,xlab="Position",y="Normalized Read Depth") +
##            scale_x_continuous(name="Chromosome", expand = c(0, 0),
##                       breaks = ticks,                      
#                       labels=(unique(d$CHR))) +
#              scale_y_continuous(name="Normalized Read Depth", expand = c(0, 0),
#                       limits = c(0,3)) + theme_classic()  
#            + guides (fill=FALSE)
#p


for (Acc in unique(d$Strain) ) {
  strainname = samples[which(samples$SRA_Run == Acc), ]$Strain
 l = subset(d,d$Strain == Acc)
 Title=sprintf("Chr coverage plot for %s.%s",strainname,Acc)
 p <- ggplot(l,
            aes(x=pos,y=Depth,color=factor(CHR)))  +
    scale_colour_brewer(palette = "Set2") +
    geom_point(alpha=0.9,size=1,shape=16) +
    labs(title=Title,xlab="Position",y="Normalized Read Depth") +
    scale_x_continuous(name="Chromosome", expand = c(0, 0),
                       breaks=ticks,
                       labels=(unique(d$CHR))) +
    scale_y_continuous(name="Normalized Read Depth", expand = c(0, 0),
                       limits = c(0,3)) + theme_classic() + guides(fill = FALSE)
 ggsave(sprintf("plots/StrainPlot_10kb.%s_%s.pdf",strainname,Acc),p,width=6,height=2.5)
}

#for (n in chrlist ) {
#    Title=sprintf("Chr%s depth of coverage",n)
# print(Title)
# l <- subset(d,d$CHR==n)
# l$bp <- l$Start
#p<-ggplot(l,
#           aes(x=bp,y=Depth,color=factor(Strain))) +
#        geom_point(alpha=0.7,size=0.75,shape=16) +
#    labs(title=Title,xlab="Position",y="Normalized Read Depth") +
#    scale_x_continuous(expand = c(0, 0), name="Position") +
#    scale_y_continuous(name="Normalized Read Depth", expand = c(0, 0),
#                       limits = c(0,3)) + theme_classic() +
#    guides(fill = guide_legend(keywidth = 3, keyheight = 1))
# ggsave(sprintf("plots/ChrPlot_10kb.Chr%s.pdf",n),p,width=7,height=2.5)
# p
#}
