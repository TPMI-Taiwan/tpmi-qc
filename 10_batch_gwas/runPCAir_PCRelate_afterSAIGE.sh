#!/bin/bash

cat BatchSAIGE/*/p5e8_SNP.txt | cut -f3 | sort | uniq > BatchEffects_SNP.list

plink --bfile ../09_qc_within_han/han_geno002_maf001_checksex_het_maf001.autosome.hwe6 --exclude BatchEffects_SNP.list --make-bed --out han_QC_rmbatcheffects.autosome

plink2.4 --bfile han_QC_rmbatcheffects.autosome --exclude HighLD_SNP.list --indep-order 2 --indep-pairwise 1000kb 0.2 --maf 0.05 --out ld

plink --bfile han_QC_rmbatcheffects.autosome --extract ld.prune.in --make-bed --out tpm1.han.afterQC.rmbatcheffects.ldpruned

Rscript runPCAir_PCRelate_afterSAIGE.R
