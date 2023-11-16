#!/bin/R

library(GENESIS)
library(GWASTools)
library(SNPRelate)
library(dplyr)

snpgdsBED2GDS(bed.fn = "tpm1.han.afterQC.ldpruned.bed", bim.fn = "tpm1.han.afterQC.ldpruned.bim", fam.fn = "tpm1.han.afterQC.ldpruned.fam", out.gdsfn = "tpm1.han.afterQC.ldpruned.gds")

gds <- snpgdsOpen("tpm1.han.afterQC.ldpruned.gds")
king <- snpgdsIBDKING(gds, type='KING-robust', num.thread=80, verbose=T)
kin2gds(king, 'tpm1.han.afterQC.ldpruned.kin.gds')
KINGmat <- openfn.gds('tpm1.han.afterQC.ldpruned.kin.gds')
snpgdsClose(gds)

geno <- GdsGenotypeReader(filename = "tpm1.han.afterQC.ldpruned.gds")
genoData <- GenotypeData(geno)
mypcair <- pcair(genoData, kinobj = KINGmat, divobj = KINGmat, num.cores=80, verbose=T, maf=0.05, missing.rate=0.01, algorithm='randomized', eigen.cnt = 32)

summary(mypcair)
colnames(mypcair$vectors) = sapply(1:32, function(x) paste0('PCAiR',x))
write.csv(mypcair$vectors, file="tpm1.han.afterQC.PCAir", col.names=T, row.names=T, sep='\t', quote=F)
write.csv(mypcair$rels, file="tpm1.han.afterQC.relatedsamples", col.names=T, row.names=F, sep='\t', quote=F)
write.csv(mypcair$unrels, file="tpm1.han.afterQC.unrelatedsamples", col.names=T, row.names=F, sep='\t', quote=F)
write.table(mypcair$values, 'tpm1.han.afterQC.eigenvalue.txt', col.names=T, row.names=T, sep='\t', quote=F)
write.table(mypcair$varprop, 'tpm1.han.afterQC.varpop.txt', col.names=T, row.names=T, sep='\t', quote=F)
