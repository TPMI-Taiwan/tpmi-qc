#!/bin/bash


ls ../01_qc_by_batch/*/*_geno005.fam | sed 's/.fam//g' > merge.bfiles

plink --merge-list merge.bfiles --make-bed --out merge --extract ../01_qc_by_batch/stage1_1-3_intersct.bim 
[[ $? -ne 0 ]] && exit

plink --bfile merge --make-bed --out merge.rm_mis_diff_gt002 --exclude ../02_snp_missing_diff/missing_diff.gt_002.txt
[[ $? -ne 0 ]] && exit

plink --bfile merge.rm_mis_diff_gt002 --make-bed --out merge.rm_mis_diff_gt002.rm_af_diff_gt_01 --exclude ../03_snp_freq/af_diff_gt_01.id

