library(pophelper)

inds <- read.table("NcrassaOR74A.Run1.popset",header=FALSE,stringsAsFactors=F)
#inds$V1
ffiles <- list.files(path=".",pattern="*.meanQ",full.names=T)
flist <- readQ(files=ffiles)

rownames(flist[[1]]) <- (inds$V1)
if(length(unique(sapply(flist,nrow)))==1) flist <- lapply(flist,"rownames<-",inds$V1)
# show row names of all runs and all samples
#lapply(flist, rownames)

tr1 <- tabulateQ(qlist=flist)
summariseQ(tr1, writetable=TRUE)
