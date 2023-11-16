#!/bin/bash

batches=$1	## batch name list

echo -e "batch\tsite\traw_ind\traw_snp\taf_geno01_snp\taf_mind01_ind\taf_geno005_snp" > qc_by_report.txt

while read batch
do
	raw_snp=`grep -w 'variants loaded from .bim file' ${batch}/${batch}_geno01.log | cut -d' ' -f1`
	raw_sample=`grep -w 'loaded from .fam' ${batch}/${batch}_geno01.log | cut -d' ' -f1`
	site=`echo ${batch} | cut -d_ -f1`
	snp_1=`cat ${batch}/${batch}_geno01.bim | wc -l`
	ind_1=`cat ${batch}/${batch}_geno01_mind01.fam | wc -l`
	snp_2=`cat ${batch}/${batch}_geno01_mind01_geno005.bim | wc -l`
	
	echo -e "${batch}\t${site}\t${raw_sample}\t${raw_snp}\t${snp_1}\t${ind_1}\t${snp_2}"
done < $batches >> qc_by_report.txt

