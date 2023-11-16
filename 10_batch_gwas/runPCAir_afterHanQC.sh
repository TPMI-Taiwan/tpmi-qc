#!/bin/bash

plink2.4 --bfile ../09_qc_within_han/han_geno002_maf001_checksex_het_maf001.autosome.hwe6 --exclude ../HighLD_SNP.list --indep-order 2 --indep-pairwise 1000kb 0.2 --maf 0.05 --out ld

plink --bfile ../09_qc_within_han/han_geno002_maf001_checksex_het_maf001.autosome.hwe6 --extract ld.prune.in --make-bed --out tpm1.han.afterQC.ldpruned

Rscript runPCAir_afterHanQC.R
