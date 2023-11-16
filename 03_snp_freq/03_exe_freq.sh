#!/bin/bash

batches=$1	## batch list (ID)


###
### Extract SNPs which frequency of any two batches have difference > 0.1
###


while read batch
do
	echo $batch
	echo -e "${batch}" > ${batch}.frq
	grep -w -f ../01_qc_by_batch/stage1_1-3_intersct.id ../01_qc_by_batch/$batch/${batch}_geno01_mind01_geno005.frq | awk '{print $5}' >> ${batch}.frq
done < $batches

f=`ls ../01_qc_by_batch/*/*_geno01_mind01_geno005.frq | head -n1`
echo "id" > id.txt
grep -w -f ../01_qc_by_batch/stage1_1-3_intersct.id $f | awk '{print $2}' >> id.txt

paste id.txt *.frq > all_freq.txt
Rscript filter.R
[[ $? -ne 0 ]] && exit

ls *frq | shuf | split -l 23
for i in `ls xa*`
do
	 char=`echo "${i: -1}"`
	 paste `cat xa$char | sort` > frq.$char.txt
done
