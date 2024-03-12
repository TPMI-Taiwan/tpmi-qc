#!/bin/bash

batch=$1
mkdir BatchSAIGE/$batch

# step1
R --slave --no-restore --file=/path/to/SAIGE/step1_fitNULLGLMM.R --args \
	--plinkFile=../09_qc_within_han/han_geno002_maf001_checksex_het_maf001.autosome.hwe6 \
	--phenoFile=pheno.txt \
	--phenoCol=$batch \
	--traitType=binary \
	--covarColList=SEX,PCAiR1,PCAiR2,PCAiR3,PCAiR4,PCAiR5,PCAiR6,PCAiR7,PCAiR8,PCAiR9,PCAiR10 \
	--qCovarColList=SEX \
	--outputPrefix=BatchSAIGE/$batch/step1_output \
	--nThreads 30 \
	--LOCO=FALSE

# step2
R --slave --no-restore --file=/path/to/SAIGE/step2_SPAtests.R --args \
	--bedFile=../09_qc_within_han/han_geno002_maf001_checksex_het_maf001.autosome.hwe6.bed \
	--bimFile=../09_qc_within_han/han_geno002_maf001_checksex_het_maf001.autosome.hwe6.bim \
	--famFile=../09_qc_within_han/han_geno002_maf001_checksex_het_maf001.autosome.hwe6.fam \
	--AlleleOrder=alt-first \
	--is_imputed_data=FALSE \
	--LOCO=FALSE \
	--GMMATmodelFile=BatchSAIGE/$batch/step1_output.rda \
	--varianceRatioFile=BatchSAIGE/$batch/step1_output.varianceRatio.txt 
	--SAIGEOutputFile=BatchSAIGE/$batch/step2_output

awk '{if($13 < 5e-8)print}' BatchSAIGE/$batch/step2_output > BatchSAIGE/$batch/p5e8_SNP.txt
