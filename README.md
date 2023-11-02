# TPMI Data QC
## Tools
* PLINK and PLINK2 (> 2.00a4)
* PCAiR
* ADMIXTURE
* PC-Relate
* PRIMUS

## Packages
### python
* pandas
* matplotlib
* numpy

### R
* scales
* tidyverse
* SAIGE
* GENESIS
* GWASTools
* SNPRelate
* dplyr

## Download Data
1. TPMI special SNPs 清單: tpm.remove.affy.list / tpm2.remove.affy.list (for step 2-2)
2. 1000 Genomes Project 資料 (for step 3-1, 3-4)
    * SNP data
        * 格式: PLINK binary fileset
        * 樣本: unrelated samples (參考資料 1kGP.3202_samples.pedigree_info.txt ([download](http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/working/))
        * chromosome: chr1-chr22
        * exclude SNPs in high LD region
    * 樣本資訊: igsr_samples.tsv ([download](https://www.internationalgenome.org/data-portal/sample))
        ```
        Sample    Sex    Biosample ID    Population code    Population name    Superpopulation code    Superpopulation name    Population elastic ID    Data collections
        HG00271    male    SAME123417    FIN    Finnish    EUR    European Ancestry    FIN    1000 Genomes on GRCh38,1000 Genomes 30x on GRCh38,1000 Genomes phase 3 release,1000 Genomes phase 1 release,Geuvadis
        HG00276    female    SAME123424    FIN    Finnish    EUR    European Ancestry    FIN    1000 Genomes on GRCh38,1000 Genomes 30x on GRCh38,1000 Genomes phase 3 release,1000 Genomes phase 1 release,Geuvadis
        ```
3. SGDP 資料 (for step 3-1, 3-4)
    * SNP data
        * 格式: PLINK binary filest
        * 樣本: ALL
        * chromosome: chr1-chr22
    * 樣本資訊: SGDP_metadata.279publiu.21signedLetter.44Fan.samples.txt ([download](https://sharehost.hms.harvard.edu/genetics/reich_lab/sgdp/SGDP_metadata.279public.21signedLetter.44Fan.samples.txt))
        ```
        #Sequencing_Panel       Illumina_ID     Sample_ID       Sample_ID(Aliases)      SGDP_ID Population_ID   Region  Country Town    Contributor     Gender  Latitude        Longitude       DNA_Source      Embargo "SGDP-lite category: X=FullyPublic, Y=SignedLetterNoDelay, Z=SignedLetterDelay, DO_NOT_USE=do.not.use"
        B       SS6004478       IHW9118 IHW9118 B_Australian-3  Australian      Oceania Australia       Cell_line_repository_sampling_location_unknown  ECCAC   U       -13     143     Genomic_from_cell_lines FullyPublic     X
        B       SS6004477       IHW9193 IHW9193 B_Australian-4  Australian      Oceania Australia       Cell_line_repository_sampling_location_unknown  ECCAC   M       -13     143     Genomic_from_cell_lines FullyPublic     X
        ```
4. High LD 區間的 TPMI SNPs 清單 (High LD regions downloaded from [here](https://genome.sph.umich.edu/wiki/Regions_of_high_linkage_disequilibrium_(LD)))  (for step 3-1)

## Required Files
1. PLINK binary fileset (prefix) 檔案路徑清單，格式可參考 [plink](https://www.cog-genomics.org/plink/1.9/data#merge_list)
    ```
    /tpmi/TPM1/bfile/b000_000_000
    /tpmi/TPM1/bfile/b000_000_001
    /tpmi/TPM1/bfile/b000_000_005
    ```
2. batch 名稱清單
    ```
    b000_000_000
    b000_000_001
    b000_000_005
    ```
3. sample/batch 資訊 (IID, batch, site)
    ```
    IID batch site
    A000000 b000_000_000 siteA
    B000000 b000_000_000 siteA
    C000000 b000_000_001 siteB
    D000000 b000_000_005 siteC
    ```
4. 花蓮慈濟醫院樣本清單 (TZUCHI_HL.id, for step 3-4)
    ```
    A000000
    B000000
    ```
5. 樣本年齡清單 (age.list、for step 5)
    ```
    A000000 A000000 40
    B000000 B000000 50
    C000000 C000000 65
    ```
6. 樣本性別清單 (sex.list、for step 5)
    ```
    A000000 A000000 Female
    B000000 B000000 Female
    C000000 C000000 Male
    ```
7. 樣本擁有的病歷數量 (emr_count.txt、for step 5。非必要。篩選樣本的優先序，病歷數量多的樣本優先挑選)
    ```
    FID IID COUNT
    A000000 A000000 177
    B000000 B000000 27
    C000000 C000000 102
    ```
8. PMI special SNPs list
    * TPM1: tpm.remove.affy.list
    * TPM2: tpm2.remove.affy.list
## 1. Initial QC by batch

### 1-1 QC by batch (01_qc_by_batch)
步驟 QC 包含
  * SNPs missing rate > 10%
  * Individual missing rate > 10%
  * SNPs missing rate > 5%
```
./01_exe.sh {BFILE_LIST}
./02_report.sh {BATCH_NAME_LIST} ### optional
```
### 1-2 Missing rate difference check (02_snp_missing_diff)
挑出任兩個 batch 的 SNP missing rate 最大相差值 > 0.02 的 SNPs
```
./02_exe.sh {BATCH_NAME_LIST}
```
### 1-3 Allele frequency difference check (03_snp_freq)
挑出任兩個 batch 的 SNP frequency 差異 > 0.1 的 SNPs
```
./03_exe_freq.sh {BATCH_NAME_LIST}
```
## 2. Merge batches and basic QC
### 2-1 Merge (04_merge)
此步驟合併且移除1-2和1-3挑選出(差異太大)的 SNPs
```
./04_exe_uniq.sh
```
### 2-2 QC after merge (05_merge_qc)
此步驟將 2-1 合併後的檔案再 QC 一次，依序移除
  * special SNPs: tpm.remove.affy.list/tpm2.remove.affy.list
  * duplicate SNPs
  * individual missing rate > 5%
  * SNPs missing rate > 2%

同時產生PCA要用的 common SNPs
```
./05_exe.sh ../tpm.remove.affy.list
```
## 3. Population assignment
此步驟目的為辨識出 Han 族群。

以 1000 Genomes Project 和 SGDP 為輔助，先用 PCA 分出 EAS 族群，再用 Admixture 分出 Han 族群。
### 3-1 PCA (06_pca)
用 1000 Genome Projects、SGDP 和 TPMI 交集的 SNPs 做 PCA。
```
./06_exe.sh
```
### 3-2 PCAiR (07_eas_pcair)
此步驟根據 PCA 結果挑出 TPM1 EAS 族群，QC後執行 PCAir 產生 EAS 的 PCA。
  * 移除 SNPs missing rate > 2%
  * 移除 MAF < 0.01
```
./07_exe.sh
```
### 3-3 Admixture
此步驟用 Admixture 將 Han 從 EAS 中區分出，包含建立 reference 及 assignment 。

### 3-3-1 Reference (08_admixture/ref)
1. 挑選 2594 1KG樣本 + random 3,000 TPMI  樣本，執行 admixture
2. 以上步驟執行5次
3. 挑出 5個 run 中、在任一族群獲得分數超過 0.7 的樣本 (TPM2為任一族群最高分數超過0.65)
```
./08_exe.sh {TZUCHI_HL_ID_LIST}
```
將分數 > 0.7 的樣本 (TPMI + 2594 1000 genomes project + 3 SGDP) 合起來再執行一次 Admixture。
```
cd refQ
./08_exe_refQ.sh
```
output 檔 *.P 作為 reference panel。
### 3-3-2 Projection (08_admixture/project_eas)
將其他樣本 project 到 reference 
```
./08_exe_project.sh
```
最高分 > 0.4 且 >第二高分 0.1，則將樣本 assign 此最高分所屬的族群。
## 4. QC within Han

###  4-1 QC (09_qc_within_han)
1. 挑出 TPMI 中 assign 為 Han 的樣本並 QC
    * 移除 SNPs missing rate > 2%
    * 移除 MAF < 0.01
2. 檢查樣本性別
    * 移除 plink --check-sex fail 的樣本
    * 移除與病歷資料提供性別 "相反" 之樣本
3. 檢查 Heterozygosity (F coefficient)
    * 移除 F score > 0.2 & < 0.2 的樣本
4. 再移除 MAF < 0.01 的 SNPs
5. Autosome
6. HWE <1e-6
``` 
./09_exe.sh
```

###  4-2 Batch GWAS (10_batch_gwas)
這個步驟目的為去除 batch effect，方法是將兩兩 batches 執行 GWAS，移除顯著的SNPs。

Generate phenotype file (run.all.txt).
```
./table.py {BATCH_INFO}
 ```
Run PCA after Han QC. This step would generate 32 PCs for SAIGE batch GWAS.
```
./runPCAir_afterHanQC.sh
```
Combine phenotype, sex and PCs being covariates (pheno.txt)
pheno.txt file contains the following columns
```
IID SEX PCAiR1  PCAiR2  PCAiR3  PCAiR4  PCAiR5  PCAiR6  PCAiR7  PCAiR8  PCAiR9  PCAiR10 Batch_001vsBatch_002    Batch_001vsBatch_003
```
Run Batch GWAS by SAIGE. This step would generate SAIGE GWAS output and extract out SNPs whose p-value < 5e-8
```
./runSAIGE.sh
```
Remove all significant SNPs and Run PCA & PCRelate. This step would generate 32 PCs and kinship between sample pairs for PRIMUS
```
./runPCAir_PCRelate_afterSAIGE.sh
```
Note: If running out of memory, you may want to separate samples, please refer to https://github.com/UW-GAC/analysis_pipeline/tree/master#relatedness-and-population-structu

## 5. Pedigrees re-construction and maximum unrelated set (11_PRIMUS)
建立 Max unrelated set  以及 pedigrees re-construction

**1. Max unrelated set**   

runs maximum unrelated set
```sh
perl PRIMUS_v1.9.0/bin/run_PRIMUS.pl -i FILE=../10_batch_gwas/tpm1.han.afterQC.rmbatcheffects_pcrelate_forPRIMUS.txt IBD0=5 IBD1=6 IBD2=7 PI_HAT=8 --no_PR --high_qtrait emr_count.txt --degree_rel_cutoff 3 -o imus_3degree
```
Then merge maximum independent set from PRIMUS and other unrelated samples to get maximum unrelated set.
```sh
grep -w -v -f <(cut -f1,3 ../10_batch_gwas/tpm1.han.afterQC.rmbatcheffects_pcrelate_forPRIMUS.txt |tr '\t' '\n'|sort | uniq) ../09_qc_within_han/han_geno002_maf001_checksex_het_maf001.autosome.hwe6.fam |cut -d' ' -f1 > not_in_primus.id
cat not_in_primus.id imus_3degree/tpm1.han.afterQC.rmbatcheffects_pcrelate_forPRIMUS.txt_maximum_independent_set |grep -v IID| sed 's/\t//g' | sort > maximum_independent_set.3_degree.id
```
**2. pedigrees re-construction**

runs pedigree reconstruction
```sh
perl PRIMUS_v1.9.0/bin/run_PRIMUS.pl -i FILE=../10_batch_gwas/tpm1.han.afterQC.rmbatcheffects_pcrelate_forPRIMUS.txt IBD0=5 IBD1=6 IBD2=7 PI_HAT=8 --no_IMUS --age_file age.list --sexes FILE=sex.list SEX=3 MALE=Male FEMALE=Female --degree_rel_cutoff 3 -o tpm1_han_PR_3degre
```
