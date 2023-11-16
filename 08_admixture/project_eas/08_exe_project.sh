#!/bin/bash


plink --bfile ../../06_pca/pca --keep ../../07_eas_pcair/tpm1.eas.fam --make-bed --out run
[[ $? -ne 0 ]] && exit


if [[ -e run.P.in ]]; then
       echo "run.P.in exists && remove now"
       rm -f run.P.in
fi
       
ln -s ../ref/refQ/run.P run.P.in
/usr/bin/time -v -o run.time /gfs/tpmi/jps/arrayQC/dist/admixture_linux-1.3.0/admixture -P run.bed 5 -j144 &> run.log
if [[ $? -ne 0 ]]; then
	echo "### ERROR: see run.log for details." && exit
fi

python3.11 cal.py run 5 &> cal.log
if [[ $? -ne 0 ]]; then
	echo "### ERROR: see cal.log for details." && exit
fi
