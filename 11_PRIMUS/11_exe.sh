#!/bin/bash

### pedigrees re-construction

# this step takes long time
perl PRIMUS_v1.9.0/bin/run_PRIMUS.pl -i FILE=../10_batch_gwas/tpm1.han.afterQC.rmbatcheffects_pcrelate_forPRIMUS.txt IBD0=5 IBD1=6 IBD2=7 PI_HAT=8 --no_IMUS --age_file age.list --sexes FILE=sex.list SEX=3 MALE=Male FEMALE=Female --degree_rel_cutoff 3 -o tpm1_han_PR_3degree

#### max unrelated set
perl PRIMUS_v1.9.0/bin/run_PRIMUS.pl -i FILE=../10_batch_gwas/tpm1.han.afterQC.rmbatcheffects_pcrelate_forPRIMUS.txt IBD0=5 IBD1=6 IBD2=7 PI_HAT=8 --no_PR --high_qtrait emr_count.txt --degree_rel_cutoff 3 -o imus_3degree

grep -w -v -f <(cut -f1,3 ../10_batch_gwas/tpm1.han.afterQC.rmbatcheffects_pcrelate_forPRIMUS.txt |tr '\t' '\n'|sort | uniq) ../09_qc_within_han/han_geno002_maf001_checksex_het_maf001.autosome.hwe6.fam |cut -d' ' -f1 > not_in_primus.id

cat not_in_primus.id imus_3degree/tpm1.han.afterQC.rmbatcheffects_pcrelate_forPRIMUS.txt_maximum_independent_set |grep -v IID| sed 's/\t//g' | sort > maximum_independent_set.3_degree.id
