#!/bin/bash
pop_assign_gt04=$1		# 08_admixture/project_eas/run.pop_assign.gt04_v4.id
emr_gender_list=$2	

c=`awk '{print $2}' ../05_merge_qc/stage1_rmAffy_rmdup_mind005_geno002.fam ${emr_gender_list} | sort | uniq -c| sed 's/^\s*//g'| grep -v '^2\b'|wc -l`
[[ $c -ne 0 ]] && echo 'ID in geno data and emr_gender_list inconsistent' && exit

grep -wf $pop_assign_gt04 ../05_merge_qc/stage1_rmAffy_rmdup_mind005_geno002.fam > han.fam

plink --bfile ../05_merge_qc/stage1_rmAffy_rmdup_mind005_geno002 --keep han.fam --make-bed --out han
[[ $? -ne 0 ]] && exit

plink --bfile han --make-bed --out han_geno002 --geno 0.02
[[ $? -ne 0 ]] && exit

plink --bfile han_geno002 --make-bed --out han_geno002_maf001 --maf 0.01
[[ $? -ne 0 ]] && exit

plink --bfile han_geno002_maf001 --check-sex --out check_sex
[[ $? -ne 0 ]] && exit

tail +2 check_sex.sexcheck | grep -v OK | awk '{if($3!=0)print $1}' > sex_not_ok.id
Rscript checkEMRSex.R
grep -wf <(cat sex_not_ok.id emr_geno_inconsistent_gender.id emr_geno_gender_fail.id) han_geno002_maf001.fam > sex_check_failed.fam

plink --bfile han_geno002_maf001 --remove sex_check_failed.fam --make-bed --out han_geno002_maf001_checksex
[[ $? -ne 0 ]] && exit

plink --bfile han_geno002_maf001_checksex --het --out het_check 
[[ $? -ne 0 ]] && exit

awk '{if($6<-0.2||$6>0.2)print $1}' het_check.het | grep -v FID > het_out_of_02.id
grep -wf het_out_of_02.id han_geno002_maf001_checksex.fam > het_out_of_02.fam
plink --bfile han_geno002_maf001_checksex --remove het_out_of_02.fam --make-bed --out han_geno002_maf001_checksex_het
[[ $? -ne 0 ]] && exit

plink --bfile han_geno002_maf001_checksex_het --make-bed --out han_geno002_maf001_checksex_het_maf001 --maf 0.01
[[ $? -ne 0 ]] && exit

plink --bfile han_geno002_maf001_checksex_het_maf001 --autosome --make-bed --out han_geno002_maf001_checksex_het_maf001.autosome
[[ $? -ne 0 ]] && exit

plink --bfile han_geno002_maf001_checksex_het_maf001.autosome --hwe 1e-6 --out han_geno002_maf001_checksex_het_maf001.autosome.hwe6 --make-bed
[[ $? -ne 0 ]] && exit
#
#### plot
##Rscript plot_sex_f.R
