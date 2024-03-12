#!/bin/bash

onekg_all=$1	#../1kg.tpm2.autosome.exHighLD_hg38.snps_only.maf001
sgdp_all=$2	#../sgdp.asia_oceania.tpm2.autosome.snps_only.maf001
onekg_comm=1kg_stage2_comm.autosome.exHighLD.snps_only.maf001


###
### Doing PCA with intersection SNPs from 1000 Genome Projects, SGDP and TPMI
###


comm -12 <(cut -f2 ../05_merge_qc/comm_var_maf005.bim | sort) <(cut -f2 comm_var_maf005.update-name.bim | sort) > tpmi_stage1.id
plink --bfile $onekg_all --extract tpmi_stage1.id --make-bed --out $onekg_comm


## intersect with SGDP common variants
plink --bfile $onekg_comm --extract <(cut -f2 $sgdp_all.bim) --make-bed --out $onekg_comm.sgdp_snp
[[ $? -ne 0 ]] && exit

plink --bfile $onekg_comm.sgdp_snp --indep-pairwise 1000kb 1 0.1 --out for_pca
[[ $? -ne 0 ]] && exit

plink --bfile $onekg_comm --extract for_pca.prune.in --make-bed --out 1kg.prune.in
[[ $? -ne 0 ]] && exit

plink --bfile $sgdp_all --extract for_pca.prune.in --make-bed --out sgdp.prune.in
[[ $? -ne 0 ]] && exit

plink --bfile ../05_merge_qc/stage1_rmAffy_rmdup_mind005_geno002 --extract for_pca.prune.in --make-bed --out tpm2.prune.in
[[ $? -ne 0 ]] && exit


## merge 1KG, SGDP, TPMI 
ls *prune.in.fam | sed 's/\.fam//' > prune_in.bfiles
plink --merge-list prune_in.bfiles --make-bed --out pca
[[ $? -ne 0 ]] && exit


## PCA
cat 1kg.prune.in.fam | awk '{print $1" "$2" 1kg"}' > pca.cluster
cat sgdp.prune.in.fam | awk '{print $1" "$2" sgdp"}' >> pca.cluster
cat tpm2.prune.in.fam | awk '{print $1" "$2" tpm2"}' >> pca.cluster

plink --bfile pca --keep-cluster-names 1kg --within pca.cluster -freqx --out pca
[[ $? -ne 0 ]] && exit

plink --bfile pca --pca-cluster-names 1kg --within pca.cluster --pca 'header' --read-freq pca.frqx --out pca
[[ $? -ne 0 ]] && exit

