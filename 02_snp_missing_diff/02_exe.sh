#!/bin/bash

batches=$1	## batch list (ID)

###
### Extract SNPs which SNP missing rates of any two batches have difference > 0.02
###

while read batch
do
	echo $batch
	echo -e "SNP\t${batch}" > ${batch}.f_miss
	grep -w -f ../01_qc_by_batch/stage1_1-3_intersct.id ../01_qc_by_batch/$batch/${batch}_geno01_mind01_geno005.lmiss | awk '{print $2"\t"$5}' >> ${batch}.f_miss
done < $batches

paste *f_miss > all_f_miss.txt

count=`wc -l $batches | cut -d' ' -f1`
python3.11 plotMissingDifferenc.py $count
