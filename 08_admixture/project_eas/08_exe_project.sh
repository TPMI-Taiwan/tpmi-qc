#!/bin/bash

plink --bfile ../../06_pca/pca --keep ../../07_eas_pcair/tpm2.eas.fam --extract <(cut -f2 ../../05_merge_qc/stage1_rmAffy_rmdup_mind005_geno002.bim) --make-bed --out run
[[ $? -ne 0 ]] && exit

if [[ -e run.5.P.in ]]; then
       echo "run.5.P.in exists && remove now"
       rm -f run.5.P.in
fi
       
ln -s ../ref/refQ/run.5.P run.5.P.in
/usr/bin/time -v -o admixture.time /opt/app/admixture_linux-1.3.0/admixture -P run.bed 5 -j144 &> admixture.log
if [[ $? -ne 0 ]]; then
	echo "### ERROR: see $(readlink -f admixture.log) for details." && exit
fi

python3.11 ../ref/cal.py run 5 ../igsr_samples.tsv &> cal.log
if [[ $? -ne 0 ]]; then
	echo "### ERROR: see $(readlink -f cal.log) for details." && exit
fi

