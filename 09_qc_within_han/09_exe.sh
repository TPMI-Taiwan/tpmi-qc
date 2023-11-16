#!/bin/bash

grep -w -f ../08_admixture/project_eas/run.pop_assign.gt04_v3.id ../05_merge_qc/stage1_rmAffy_rmdup_mind005_geno002.fam > han.fam

plink --bfile ../05_merge_qc/stage1_rmAffy_rmdup_mind005_geno002 --keep han.fam --make-bed --out han
[[ $? -ne 0 ]] && exit

plink --bfile han --make-bed --out han_geno002 --geno 0.02
[[ $? -ne 0 ]] && exit

plink --bfile han_geno002 --make-bed --out han_geno002_maf001 --maf 0.01
[[ $? -ne 0 ]] && exit

plink --bfile han_geno002_maf001 --check-sex --out check_sex
[[ $? -ne 0 ]] && exit

grep -v OK check_sex.sexcheck | awk '{print $1}' > sex_not_ok.id
sed -e 's/Female/2/g' -e 's/Male/1/g' tpm1_geno_sex_ehr_sex.txt|awk '{if(($4+$5)==3)print}' | cut -f2 > sex_opposite_with_ehr.id
grep -w -f <(cat sex_not_ok.id sex_opposite_with_ehr.id) han_geno002_maf001.fam > sex_check_failed.fam

plink --bfile han_geno002_maf001 --remove sex_check_failed.fam --make-bed --out han_geno002_maf001_checksex
[[ $? -ne 0 ]] && exit

plink --bfile han_geno002_maf001_checksex --het --out het_check 
[[ $? -ne 0 ]] && exit

awk '{if($6<-0.2||$6>0.2)print $1}' het_check.het | grep -v FID > het_out_of_02.id
grep -w -f het_out_of_02.id han_geno002_maf001_checksex.fam > het_out_of_02.fam
plink --bfile han_geno002_maf001_checksex --remove het_out_of_02.fam --make-bed --out han_geno002_maf001_checksex_het
[[ $? -ne 0 ]] && exit

plink --bfile han_geno002_maf001_checksex_het --make-bed --out han_geno002_maf001_checksex_het_maf001 --maf 0.01
[[ $? -ne 0 ]] && exit

plink --bfile han_geno002_maf001_checksex_het_maf001 --autosome --make-bed --out han_geno002_maf001_checksex_het_maf001.autosome
[[ $? -ne 0 ]] && exit

plink --bfile han_geno002_maf001_checksex_het_maf001.autosome --hwe 1e-6 --out han_geno002_maf001_checksex_het_maf001.autosome.hwe6 --make-bed
[[ $? -ne 0 ]] && exit

### plot
#Rscript plot_sex_f.R
