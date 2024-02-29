#!/bin/bash

ld_region_bed=$1

### Extracting TPM1 EAS according to PCA results, QC (remove):
###	1. SNPs missing rate > 2%
### 	2. MAF < 0.01
### Running PCAir


grep -wf ../06_pca/pca.eas.id ../05_merge_qc/stage1_rmAffy_rmdup_mind005_geno002.fam > tpm1.eas.fam

plink --bfile ../05_merge_qc/stage1_rmAffy_rmdup_mind005_geno002 --keep tpm1.eas.fam --make-bed --out tpm1.eas
[[ $? -ne 0 ]] && exit

plink --bfile tpm1.eas --make-bed --out tpm1.eas.geno002 --geno 0.02
[[ $? -ne 0 ]] && exit

plink --bfile tpm1.eas --make-bed --out tpm1.eas.geno002_maf001 --maf 0.01
[[ $? -ne 0 ]] && exit

plink2.4 --bfile tpm1.eas.geno002_maf001 --exclude range $ld_region_bed --indep-order 2 --indep-pairwise 1000kb 0.2 --maf 0.05 --out ld
[[ $? -ne 0 ]] && exit

plink --bfile tpm1.eas.geno002_maf001 --extract ld.prune.in --make-bed --out tpm1.eas.afterQC.ldpruned
[[ $? -ne 0 ]] && exit

Rscript runPCAir.R
