# TPMI data QC
## Tools
* [PLINK](https://www.cog-genomics.org/plink/)
* [PLINK2](https://www.cog-genomics.org/plink/2.0/) (>= 2.00a4)
* [ADMIXTURE](https://dalexander.github.io/admixture/)
* [PRIMUS](https://primus.gs.washington.edu/primusweb/)

## Packages
### Python
* pandas
* matplotlib
* numpy

### R
* scales
* tidyverse
* SAIGE
* [GENESIS](https://rdrr.io/bioc/GENESIS/)
* GWASTools
* SNPRelate
* dplyr

## Downloaded data
1. TPMI special SNPs 清單: `tpm.remove.affy.list` / `tpm2.remove.affy.list` (for step 2-2)
2. 1000 Genomes Project 資料 (`ONEKG_BFILE`, for step 3-1, 3-4)
    * 下載 VCF ([http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/working/20201028_3202_phased/]) 檔案並只保留 biallelic SNPs 
    * SNP data
        * 格式: PLINK binary fileset
        * 樣本: unrelated samples (參考資料 `1kGP.3202_samples.pedigree_info.txt` ([download](http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/working/)))
        * chromosome: chr1-chr22
        * 排除 high linkage disequilibrium (LD) 區間內的 SNPs
    * 樣本資訊: `igsr_samples.tsv` ([download](https://www.internationalgenome.org/data-portal/sample))
        ```
        Sample    Sex    Biosample ID    Population code    Population name    Superpopulation code    Superpopulation name    Population elastic ID    Data collections
        HG00271    male    SAME123417    FIN    Finnish    EUR    European Ancestry    FIN    1000 Genomes on GRCh38,1000 Genomes 30x on GRCh38,1000 Genomes phase 3 release,1000 Genomes phase 1 release,Geuvadis
        HG00276    female    SAME123424    FIN    Finnish    EUR    European Ancestry    FIN    1000 Genomes on GRCh38,1000 Genomes 30x on GRCh38,1000 Genomes phase 3 release,1000 Genomes phase 1 release,Geuvadis
        ```
3. SGDP 資料 (`SGDP_BFILE`, for step 3-1, 3-4)
    * SNP data
        * 格式: PLINK binary filest
        * 樣本: ALL
        * chromosome: chr1-chr22
    * 樣本資訊: `SGDP_metadata.279publiu.21signedLetter.44Fan.samples.txt` ([download](https://sharehost.hms.harvard.edu/genetics/reich_lab/sgdp/SGDP_metadata.279public.21signedLetter.44Fan.samples.txt)) (SGDP_SAMPLE_LIST, for step 3-3-1)
        ```
        #Sequencing_Panel       Illumina_ID     Sample_ID       Sample_ID(Aliases)      SGDP_ID Population_ID   Region  Country Town    Contributor     Gender  Latitude        Longitude       DNA_Source      Embargo "SGDP-lite category: X=FullyPublic, Y=SignedLetterNoDelay, Z=SignedLetterDelay, DO_NOT_USE=do.not.use"
        B       SS6004478       IHW9118 IHW9118 B_Australian-3  Australian      Oceania Australia       Cell_line_repository_sampling_location_unknown  ECCAC   U       -13     143     Genomic_from_cell_lines FullyPublic     X
        B       SS6004477       IHW9193 IHW9193 B_Australian-4  Australian      Oceania Australia       Cell_line_repository_sampling_location_unknown  ECCAC   M       -13     143     Genomic_from_cell_lines FullyPublic     X
        ```
4. High LD 區間的 TPMI SNPs 清單 (High LD 區間位置可參考 [Regions of high linkage disequilibrium (LD)](https://genome.sph.umich.edu/wiki/Regions_of_high_linkage_disequilibrium_(LD)))  (`HIGH_LD_REGION_BED`, for step 3-1)

## Required files & format
1. PLINK binary fileset (prefix) 檔案路徑清單，格式可參考 [plink](https://www.cog-genomics.org/plink/1.9/data#merge_list) (`BFILE_LIST`, for step 1-1)
    ```
    /tpmi/TPM1/bfile/b000_000_000
    /tpmi/TPM1/bfile/b000_000_001
    /tpmi/TPM1/bfile/b000_000_005
    ```
2. batch ID 清單 (`BATCH_ID_LIST`, for step 1-1 ~ step 1-3)
    ```
    b000_000_000
    b000_000_001
    b000_000_005
    ```
3. sample/batch 資訊 (`BATCH_INFO`, for step 4-2)
    ```
    IID batch site
    A000000 b000_000_000 siteA
    B000000 b000_000_000 siteA
    C000000 b000_000_001 siteB
    D000000 b000_000_005 siteC
    ```
4. 花蓮慈濟醫院樣本清單 (`TZUCHI_HL_LIST`, for step 3-4)
    ```
    A000000
    B000000
    ```
5. 樣本年齡清單 (`age.list`, for step 5)
    ```
    A000000 A000000 40
    B000000 B000000 50
    C000000 C000000 65
    ```
6. 樣本性別清單 (`sex.list`, for step 4 和 step 5)
    ```
    A000000 A000000 Female
    B000000 B000000 Female
    C000000 C000000 Male
    D000000 D000000 Female
    ```
7. 樣本擁有的病歷數量，作為建立 Max unrelated set 時篩選樣本的優先序，病歷數量多的樣本優先挑選。(`emr_count.txt`, for step 5)
    ```
    FID IID COUNT
    A000000 A000000 177
    B000000 B000000 27
    C000000 C000000 102
    D000000 D000000 86
    ```
    
## 1. Initial QC by batch

### 1-1 QC by batch (01_qc_by_batch)
  * 移除 SNPs missing rate > 10%
  * 移除 Individual missing rate > 10%
  * 移除 SNPs missing rate > 5%
```
./01_exe.sh {BFILE_LIST}
./report.sh {BATCH_ID_LIST} ### optional
```
### 1-2 Missing rate difference between batches (02_snp_missing_diff)
挑出任兩個 batch 之間 SNP missing rate 最大相差值 > 0.02 的 SNPs。
```
./02_exe.sh {BATCH_ID_LIST}
```
### 1-3 Allele frequency difference between batches (03_snp_freq)
挑出任兩個 batch 之間 SNP frequency 差異 > 0.1 的 SNPs。
```
./03_exe_freq.sh {BATCH_ID_LIST}
```
## 2. Merge batches and basic QC
### 2-1 Merge (04_merge)
合併 1-1 QC後的 batches，再移除 step 1-2 和 step 1-3 挑選出(差異太大)的 SNPs。
```
./04_exe_uniq.sh
```
### 2-2 QC after merge (05_merge_qc)
  * 移除 TPMI special SNPs (`tpm.remove.affy.list`)
  * 移除 Duplicated SNPs
  * 移除 Individual missing rate > 5%
  * 移除 SNPs missing rate > 2%

同時產生PCA要用的 common SNPs。
```
./05_exe.sh ../tpm.remove.affy.list
```
## 3. Population assignment
此步驟目的為辨識出 Han Chinese 族群。

以 1000 Genomes Projects 和 SGDP 資料為輔助，先用 PCA 分出 EAS 族群，再用 Admixture 從 EAS 分出 Han Chinese 族群。
### 3-1 PCA (06_pca)
用 1000 Genome Projects、SGDP 和 TPMI 交集的 SNPs 做 PCA。
```
./06_exe.sh {ONEKG_BFILE} {SGDP_BFILE}
```
根據 PCA 結果切出 EAS 族群的樣本。

<img src="https://github.com/TPMI-Taiwan/tpmi-qc/blob/readme-edits/06_pca/pca.PC1PC2.1kg.png" alt="Image" width="500" height="500"><img src="https://github.com/TPMI-Taiwan/tpmi-qc/blob/readme-edits/06_pca/pca.PC1PC2.cut_eas.tpm1.png" alt="Image" width="500" height="500">


### 3-2 PCAiR (07_eas_pcair)
根據 PCA 結果挑出 TPMI EAS 族群，QC 後執行 PCAiR 產生 EAS 的 PCs。
  * 移除 SNPs missing rate > 2%
  * 移除 MAF < 0.01
```
./07_exe.sh {HIGH_LD_REGION_BED}
```
### 3-3 Admixture
包含建立 reference, projection 以及 assignment 等步驟。

### 3-3-1 Reference (08_admixture/ref)
1. 挑選 2,594 個 1000 Genomes Project 樣本 + random 3,000 TPMI 樣本，執行 Admixture
2. 挑出在任一族群獲得分數超過門檻的樣本 (重複執行 5 次)
   * TPM1: > 0.7
   * TPM2: > 0.65
```
./08_exe.sh {IGSR_SAMPLE_LIST} {TZUCHI_HL_LIST}
```
3. 將前一步獲得的樣本合併再執行一次 Admixture。
```
cd refQ
./08_exe_refQ.sh {SGDP_SAMPLE_LIST}
```
output 檔 run.P 作為 reference panel，run.5.mean 檔為已知族群樣本在各組的平均，可以得知各個組別 (column) 所對應的族群。
### 3-3-2 Projection (08_admixture/project_eas)
將其他樣本投影 (projection) 到 reference，獲得樣本再各族群的分數。最高分 > 0.4 且比第二高分高出 0.1，則將樣本 assign 此最高分所屬的族群。
```
./08_exe_project.sh
```
*.pop_assign.txt 整理了各個樣本的最高分(max)、第二高分(second)、最高分對應到的族群(max_group)以及不同門檻會的族群assignment，條件如下
   * gt04: 最高分>0.4, 且比第二高分至少高了0.1 (- 表示不滿足此條件)
   * gt05: 最高分>0.5, 且比第二高分至少高了0.1 (- 表示不滿足此條件)
   * ... 以此類推

根據此檔案和前一步的 run.5.mean 挑出 Han Chinese 族群的樣本。

## 4. QC within Han

###  4-1 QC (09_qc_within_han)
1. 挑出 TPMI 中 assign 為 Han Chinese 族群的樣本
2. 基本 QC
    * 移除 SNPs missing rate > 2%
    * 移除 MAF < 0.01
3. 檢查樣本性別
    * 移除 plink --check-sex fail 的樣本
    * 移除與病歷資料提供性別 "相反" 之樣本
4. 檢查 Heterozygosity (F coefficient)
    * 移除 F score > 0.2 & < 0.2 的樣本
5. 再移除 MAF < 0.01 的 SNPs
6. 留下體染色體的 SNPs
7. 移除 HWE testing failed SNPs (P-value < 1e-6)
``` 
./09_exe.sh
```

###  4-2 Batch GWAS (10_batch_gwas)
將兩兩 batches 執行 GWAS 後移除顯著的SNPs，此步驟目的在去除 batch effect。

需先做出執行 GWAS 所需的 covariates 檔。
1. 產生 phenotype file (`run.all.txt`)。
```
./table.py {BATCH_INFO}
 ```
2. 執行 PCA，獲得 PCs。
```
./runPCAir_afterHanQC.sh
```
3. 合併 phenotype、sex 和 PCs 做出 `pheno.txt`，檔案內包含以下 columns：
```
IID SEX PCAiR1  PCAiR2  PCAiR3  PCAiR4  PCAiR5  PCAiR6  PCAiR7  PCAiR8  PCAiR9  PCAiR10 Batch_001vsBatch_002    Batch_001vsBatch_003
```
執行 GWAS 分析、此步驟會產生 GWAS 結果並找出顯著的位點 (p-value < 5e-8)。
```
./runSAIGE.sh
```
移除所有顯著的位點。再執行 PCA 及 PCRelate。此步驟會產生 PCs 和樣本之間的關聯性，後續會用此結果來找 max unrelated set 和重建親屬關係。
```
./runPCAir_PCRelate_afterSAIGE.sh
```
> [!NOTE]
> 若記憶體空間不足，須將樣本拆分執行，請參考 [這裡](https://github.com/UW-GAC/analysis_pipeline/tree/master#relatedness-and-population-structure)

## 5. Pedigrees re-construction and maximum unrelated set (11_PRIMUS)
建立 Max unrelated set 以及 pedigrees re-construction

**1. Max unrelated set**   

執行 PRIMUS 建立 max unrelated set (只計算有關連的樣本)。
```sh
perl PRIMUS_v1.9.0/bin/run_PRIMUS.pl -i FILE=../10_batch_gwas/tpm1.han.afterQC.rmbatcheffects_pcrelate_forPRIMUS.txt IBD0=5 IBD1=6 IBD2=7 PI_HAT=8 --no_PR --high_qtrait emr_count.txt --degree_rel_cutoff 3 -o imus_3degree
```
合併 PRIMUS 的結果以及其他無關聯的樣本即為 Maximum unrelated set。
```sh
grep -w -v -f <(cut -f1,3 ../10_batch_gwas/tpm1.han.afterQC.rmbatcheffects_pcrelate_forPRIMUS.txt |tr '\t' '\n'|sort | uniq) ../09_qc_within_han/han_geno002_maf001_checksex_het_maf001.autosome.hwe6.fam |cut -d' ' -f1 > not_in_primus.id
cat not_in_primus.id imus_3degree/tpm1.han.afterQC.rmbatcheffects_pcrelate_forPRIMUS.txt_maximum_independent_set |grep -v IID| sed 's/\t//g' | sort > maximum_independent_set.3_degree.id
```
**2. pedigrees re-construction**

執行 PRIMUS 重建親屬關係 (只計算有關連的樣本)。
```sh
perl PRIMUS_v1.9.0/bin/run_PRIMUS.pl -i FILE=../10_batch_gwas/tpm1.han.afterQC.rmbatcheffects_pcrelate_forPRIMUS.txt IBD0=5 IBD1=6 IBD2=7 PI_HAT=8 --no_IMUS --age_file age.list --sexes FILE=sex.list SEX=3 MALE=Male FEMALE=Female --degree_rel_cutoff 3 -o tpm1_han_PR_3degre
```

**3. Remove Duplicates**

選出 PI_HAT > 0.9 的 pair，移除 duplicate 、保留雙胞胎。

樣本保留規則:
1. 不生日或不同性別: 皆移除。
2. 相同生日和性別
   * 不同來源醫院: 保留病歷數較多的樣本。(視為重複收案)
   * 相同來源醫院: 若病歷數量不同、兩個樣本皆保留(視為雙胞胎)；若病歷數相同則人工查看病歷確認是否為雙胞胎或同一人。
3. 優先保留有病歷的樣本。
4. 無法確認的情況皆先予以保留。
5. 若是已知重複檢測的樣本，優先保留TPM2版本的結果。
