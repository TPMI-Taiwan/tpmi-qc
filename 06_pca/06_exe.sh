#!/bin/bash

onekg_all=../1kg.tpm1.autosome.exHighLD_hg38.snps_only.maf001
sgdp_all=../sgdp.asia_oceania.tpm1.autosome.snps_only.maf001

onekg_comm=1kg_stage2_comm.autosome.exHighLD.snps_only.maf001
sgdp_comm=sgdp_stage2_comm.autosome.snps_only.maf001


###
### Doing PCA with intersection SNPs from 1000 Genome Projects, SGDP and TPMI
###


plink --bfile $onekg_all --extract ../01_qc_by_batch/stage1_1-3_intersct.id --make-bed --out $onekg_comm
plink --bfile $sgdp_all --extract ../01_qc_by_batch/stage1_1-3_intersct.id --make-bed --out $sgdp_comm


## intersect with SGDP common variants
cut -f2 $sgdp_comm.bim > sgdp_snp.id
plink --bfile $onekg_comm --extract sgdp_snp.id --make-bed --out $onekg_comm.sgdp_snp
[[ $? -ne 0 ]] && exit

plink --bfile $onekg_comm.sgdp_snp --indep-pairwise 1000kb 1 0.1 --out for_pca
[[ $? -ne 0 ]] && exit

plink --bfile $onekg_comm --extract for_pca.prune.in --make-bed --out 1kg.prune.in
[[ $? -ne 0 ]] && exit

plink --bfile $sgdp_comm --extract for_pca.prune.in --make-bed --out sgdp.prune.in
[[ $? -ne 0 ]] && exit

plink --bfile ../05_merge_qc/stage1_rmAffy_rmdup_mind005_geno002 --extract for_pca.prune.in --make-bed --out tpm1.prune.in
[[ $? -ne 0 ]] && exit


## merge 1KG, SGDP, TPMI 
ls *prune.in.fam | sed 's/\.fam//' > prune_in.bfiles
plink --merge-list prune_in.bfiles --make-bed --out pca
[[ $? -ne 0 ]] && exit


## PCA
cat 1kg.prune.in.fam | awk '{print $1" "$2" 1kg"}' > pca.cluster
cat sgdp.prune.in.fam | awk '{print $1" "$2" sgdp"}' >> pca.cluster
cat tpm1.prune.in.fam | awk '{print $1" "$2" tpm1"}' >> pca.cluster

plink --bfile pca --keep-cluster-names 1kg --within pca.cluster -freqx --out pca
[[ $? -ne 0 ]] && exit

plink --bfile pca --pca-cluster-names 1kg --within pca.cluster --pca 'header' --read-freq pca.frqx --out pca
[[ $? -ne 0 ]] && exit


awk '$4>0.025+$3*(0.025/0.03){print $1}' pca.eigenvec | grep -v FID | sort -u | sed '1i IID' > pca.eas.id
awk '$4<=0.025+$3*(0.025/0.03){print $1}' pca.eigenvec | grep -v FID | sort -u | sed '1i IID' > pca.not_eas.id


## plot PCA
Rscript plot_cut.R tpm1.prune.in.fam PC1 PC2

