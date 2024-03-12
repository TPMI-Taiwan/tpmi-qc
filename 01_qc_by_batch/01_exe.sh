#!/bin/bash

bfile_list=$1	# PLINK binary fileset list (for merge)


while read bfile
do
	batch=`basename $bfile`
	mkdir -p ${batch} && cd ${batch}
	
	## remove SNPs missing rate > 10%
	plink --bfile ${bfile} --make-bed --out ${batch}_geno01 --geno 0.1
	[[ $? -ne 0 ]] && exit

	## remove individual missing rate > 10%
	plink --bfile ${batch}_geno01 --make-bed --out ${batch}_geno01_mind01 --mind 0.1 
	[[ $? -ne 0 ]] && exit

	## remove SNPs missing rate > 5%
	plink --bfile ${batch}_geno01_mind01 --make-bed --out ${batch}_geno01_mind01_geno005 --geno 0.05 --missing --freq
	[[ $? -ne 0 ]] && exit
	
	cd ..
done < $bfile_list

## intersection of all batches
cat $batch/${batch}_geno01_mind01_geno005.bim > a
for i in `ls */*_geno01_mind01_geno005.bim`
do
	comm -12 <(sort a) <(sort ${i}) > b
	cp b a
	count=`cat b |wc -l`
	echo $i $count
done > snp_intersect.log
mv b stage1_1-3_intersct.bim && rm a
cut -f2 stage1_1-3_intersct.bim > stage1_1-3_intersct.id
