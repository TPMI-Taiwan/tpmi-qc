#!/bin/bash

sgdp_sample=$1

[[ -e ref.id ]] && rm -f ref.id
cp ../igsr_samples.eas.id ref.id
grep -iw -e Atayal -e Ami $sgdp_sample | cut -f2 | sed 's/_/-/g' >> ref.id
cat ../tpm1.ref.id >> ref.id

chmod -w ref.id

grep -wf ref.id ../../../06_pca/pca.fam > ref.fam
plink --bfile ../../../06_pca/pca --keep ref.fam --extract <(cut -f2 ../../../05_merge_qc/stage1_rmAffy_rmdup_mind005_geno002.bim) --make-bed --out run
[[ $? -ne 0 ]] && exit

nohup /usr/bin/time -v -o admixture.time /opt/app/admixture_linux-1.3.0/admixture run.bed 5 -j144 &> admixture.log
if [[ $? -ne 0 ]]; then
	echo "### ERROR: see $(readlink -f admixture.log) for details." && exit
fi

python3.11 ../cal.py run 5 ../../igsr_samples.tsv
