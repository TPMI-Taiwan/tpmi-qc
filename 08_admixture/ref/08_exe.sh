#!/bin/bash

TZUCHI_HL=$1	## Individual who came from Hualien Tzu Chi Hospital
pop="../../igsr_samples.tsv"

if [[ ! -e $pop ]]; then
	echo "### ERROR: $pop not found" && exit
fi
grep -P 'East Asian Ancestry' $pop | sort -k8 | cut -f1 > igsr_samples.eas.id


if [[ ! -e $TZUCHI_HL ]]; then
	echo "### ERROR: $TZUCHI_HL not found" && exit
fi

grep -wf $TZUCHI_HL ../../07_eas_pcair/tpm1.eas.fam | cut -d' ' -f1 > tpm1.eas.TZUCHI_HL.id
grep -vwf $TZUCHI_HL ../../07_eas_pcair/tpm1.eas.fam | cut -d' ' -f1 > tpm1.eas.ALL_ex_TZUCHI_HL.id

split -d -l 1001 <(shuf tpm1.eas.TZUCHI_HL.id) --additional-suffix .id

for ((run=0; run<5; run++)); do
	[[ -e keep${run}.id ]] && rm keep${run}.id
	cat igsr_samples.eas.id > keep${run}.id
	cat tpm1.eas.ALL_ex_TZUCHI_HL.id | shuf | head -n 2000 >> keep${run}.id
	cat x0${run}.id >> keep${run}.id
	
	chmod -w keep${run}.id
	
	grep -w -f keep${run}.id ../../06_pca/pca.fam > keep${run}.fam
	plink --bfile ../../06_pca/pca --keep keep${run}.fam --make-bed --out run${run}
	[[ $? -ne 0 ]] && exit
	
	/usr/bin/time -v -o run${run}.time /gfs/tpmi/jps/arrayQC/dist/admixture_linux-1.3.0/admixture run${run}.bed 5 -j144 &> run${run}.log
	if [[ $? -ne 0 ]]; then
	       echo "### ERROR: see run${run}.log for details."
	fi

	python3.11 cal.py run$run 5 $pop &> cal.run$run.log
	if [[ $? -ne 0 ]]; then
	       echo "### ERROR: see cal.run$run.log for details."
	fi
done

grep -w -f <(cat run*.pop_assign.txt | awk '{if($8!="-")print $1}' | sort -u) ../../07_eas_pcair/tpm1.eas.fam | sort -u > tpm1.ref.fam
cat tpm1.ref.fam | cut -d' ' -f1 | sort -u > tpm1.ref.id
