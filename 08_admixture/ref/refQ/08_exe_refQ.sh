#!/bin/bash


[[ -e ref.id ]] && rm -f ref.id
cp ../igsr_samples.eas.id ref.id
grep -iw -e Atayal -e Ami ../../../SGDP_metadata.279public.21signedLetter.44Fan.samples.txt | cut -f2 | sed 's/_/-/g' >> ref.id
cat ../tpm1.ref.id >> ref.id

chmod -w ref.id

grep -wf ref.id ../../../06_pca/pca.fam > ref.fam
plink --bfile ../../../06_pca/pca --keep ref.fam --make-bed --out run
[[ $? -ne 0 ]] && exit

nohup /usr/bin/time -v -o run.time /gfs/tpmi/jps/arrayQC/dist/admixture_linux-1.3.0/admixture run.bed 5 -j144 &> run.log
if [[ $? -ne 0 ]]; then
       echo "### ERROR: see run.log for details." && exit
fi

pop="../../../igsr_samples.tsv"
if [[ ! -e $pop ]]; then
	echo "### ERROR: $pop not found" && exit
fi
python3.11 ../cal.py run 5 $pop
