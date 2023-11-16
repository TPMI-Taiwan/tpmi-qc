#!/bin/R

library(GENESIS)
library(GWASTools)
library(SNPRelate)
library(dplyr)

snpgdsBED2GDS(bed.fn = "tpm1.han.afterQC.rmbatcheffects.ldpruned.bed", bim.fn = "tpm1.han.afterQC.rmbatcheffects.ldpruned.bim", fam.fn = "tpm1.han.afterQC.rmbatcheffects.ldpruned.fam", out.gdsfn = "tpm1.han.afterQC.rmbatcheffects.ldpruned.gds")

gds <- snpgdsOpen("tpm1.han.afterQC.rmbatcheffects.ldpruned.gds")
king <- snpgdsIBDKING(gds, type='KING-robust', num.thread=80, verbose=T)
kin2gds(king, 'tpm1.han.afterQC.rmbatcheffects.ldpruned.kin.gds')
KINGmat <- openfn.gds('tpm1.han.afterQC.rmbatcheffects.ldpruned.kin.gds')
snpgdsClose(gds)

geno <- GdsGenotypeReader(filename = "tpm1.han.afterQC.rmbatcheffects.ldpruned.kin.gds")
genoData <- GenotypeData(geno)
mypcair <- pcair(genoData, kinobj = KINGmat, divobj = KINGmat, num.cores=80, verbose=T, maf=0.05, missing.rate=0.01, algorithm='randomized', eigen.cnt = 32)
colnames(mypcair$vectors) = sapply(1:32, function(x) paste0('PCAiR',x))
write.csv(mypcair$vectors, file="tpm1.han.afterQC.rmbatcheffects.PCAir", col.names=T, row.names=T, sep='\t', quote=F)
write.csv(mypcair$rels, file="tpm1.han.afterQC.rmbatcheffects.relatedsamples", col.names=T, row.names=F, sep='\t', quote=F)
write.csv(mypcair$unrels, file="tpm1.han.afterQC.rmbatcheffects.unrelatedsamples", col.names=T, row.names=F, sep='\t', quote=F)
write.table(mypcair$values, 'tpm1.han.afterQC.rmbatcheffects.eigenvalue.txt', col.names=T, row.names=T, sep='\t', quote=F)
write.table(mypcair$varprop, 'tpm1.han.afterQC.rmbatcheffects.varpop.txt', col.names=T, row.names=T, sep='\t', quote=F)

mypcrelate <- pcrelate(genoData, pcs = mypcair$vectors[,1:2], training.set = mypcair$unrels, BPPARAM = BiocParallel::SerialParam())

df <- mypcrelate$kinBtwn
df$k1 <- 1 - df$k2 - df$k0
df$kin <- df$kin*2
df <- df[c("ID1", "ID1", "ID2", "ID2", "k0", "k1", "k2", "kin")]
colnames(df) <- c("FID1", "IID1", "FID2", "IID2", "IBD0", "IBD1", "IBD2", "PI_HAT")
write.csv(df, "tpm1.han.afterQC.rmbatcheffects_pcrelate_forPRIMUS.txt", sep = "\t", row.names=FALSE, quote=FALSE)
