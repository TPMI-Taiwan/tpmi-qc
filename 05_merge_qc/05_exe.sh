#!/bin/bash

remove_list=$1	## TPMI special SNPs list


###
### QC, removing:
### 	1. TPMI special SNPs
###		TPM1: tpm.remove.affy.list
###		TPM2: tpm2.remove.affy.list
###	2. duplicate SNPs
###	3. individual missing rate > 5%
###	3. SNPs missing rate > 2%
###


if [[ -e removed.affy.list ]]
then
	echo "### removed.affy.list exists && remove now"
	rm removed.affy.list
fi
ln -s $remove_list removed.affy.list

plink --bfile ../04_merge/merge.rm_mis_diff_gt002.rm_af_diff_gt_01 --exclude removed.affy.list --make-bed --out stage1_rmAffy
[[ $? -ne 0 ]] && exit

plink --bfile stage1_rmAffy --list-duplicate-vars 
[[ $? -ne 0 ]] && exit

cat plink.dupvar | grep -v CHR | cut -f4 | cut -d' ' -f2- | tr ' ' '\n' > plink.dupvar.removed
plink --bfile stage1_rmAffy --exclude plink.dupvar.removed --make-bed --out stage1_rmAffy_rmdup
[[ $? -ne 0 ]] && exit

plink --bfile stage1_rmAffy_rmdup --make-bed --out stage1_rmAffy_rmdup_mind005 --mind 0.05
[[ $? -ne 0 ]] && exit

plink --bfile stage1_rmAffy_rmdup_mind005 --make-bed --out stage1_rmAffy_rmdup_mind005_geno002 --geno 0.02
[[ $? -ne 0 ]] && exit

plink --bfile stage1_rmAffy_rmdup_mind005_geno002 --make-bed --out comm_var_maf005 --maf 0.05
