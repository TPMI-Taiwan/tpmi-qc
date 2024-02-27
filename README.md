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
1. TPMI special SNPs list: `tpm.remove.affy.list` / `tpm2.remove.affy.list` (for step 2-2)
2. 1000 Genomes Project data (ONEKG_BFILE, for step 3-1, 3-4)
    * Download VCF from [FTP](http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/working/20201028_3202_phased/) and keep only SNPs which are biallelic and maximum number of alleles listed in REF and ALT
    * SNP data
        * Format: PLINK binary fileset
        * Sample: unrelated samples (Refer to `1kGP.3202_samples.pedigree_info.txt` ([download](http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/working/))) for additional information 
        * Autosome
        * Exclusions: SNPs in high linkage disequilibrium (LD) regions
    * Sample information: `igsr_samples.tsv` ([download](https://www.internationalgenome.org/data-portal/sample)) (IGSR_SAMPLE_LIST, for step 3-3-2)
        ```
        Sample    Sex    Biosample ID    Population code    Population name    Superpopulation code    Superpopulation name    Population elastic ID    Data collections
        HG00271    male    SAME123417    FIN    Finnish    EUR    European Ancestry    FIN    1000 Genomes on GRCh38,1000 Genomes 30x on GRCh38,1000 Genomes phase 3 release,1000 Genomes phase 1 release,Geuvadis
        HG00276    female    SAME123424    FIN    Finnish    EUR    European Ancestry    FIN    1000 Genomes on GRCh38,1000 Genomes 30x on GRCh38,1000 Genomes phase 3 release,1000 Genomes phase 1 release,Geuvadis
        ```
4. SGDP data (SGDP_BFILE, for step 3-1, 3-4)
    * SNP data
        * Format: PLINK binary filest
        * Sample: ALL samples
        * Autosome
    * Sample information: `SGDP_metadata.279publiu.21signedLetter.44Fan.samples.txt` ([download](https://sharehost.hms.harvard.edu/genetics/reich_lab/sgdp/SGDP_metadata.279public.21signedLetter.44Fan.samples.txt)) (SGDP_SAMPLE_LIST, for step 3-3-1)
        ```
        #Sequencing_Panel       Illumina_ID     Sample_ID       Sample_ID(Aliases)      SGDP_ID Population_ID   Region  Country Town    Contributor     Gender  Latitude        Longitude       DNA_Source      Embargo "SGDP-lite category: X=FullyPublic, Y=SignedLetterNoDelay, Z=SignedLetterDelay, DO_NOT_USE=do.not.use"
        B       SS6004478       IHW9118 IHW9118 B_Australian-3  Australian      Oceania Australia       Cell_line_repository_sampling_location_unknown  ECCAC   U       -13     143     Genomic_from_cell_lines FullyPublic     X
        B       SS6004477       IHW9193 IHW9193 B_Australian-4  Australian      Oceania Australia       Cell_line_repository_sampling_location_unknown  ECCAC   M       -13     143     Genomic_from_cell_lines FullyPublic     X
        ```
5. List of TPMI SNPs in high LD regions (HIGH_LD_REGION_BED, for step 3-1): See [Regions of high linkage disequilibrium (LD)](https://genome.sph.umich.edu/wiki/Regions_of_high_linkage_disequilibrium_(LD))  for details of these regions.

## Required files & format
1. PLINK binary fileset (prefix) path list, refer to [plink](https://www.cog-genomics.org/plink/1.9/data#merge_list) for format details. (`BFILE_LIST`, for step 1-1)
    ```
    /tpmi/TPM1/bfile/b000_000_000
    /tpmi/TPM1/bfile/b000_000_001
    /tpmi/TPM1/bfile/b000_000_005
    ```
2. List of batch ID (`BATCH_ID_LIST`, for step 1-1 ~ step 1-3)
    ```
    b000_000_000
    b000_000_001
    b000_000_005
    ```
3. Sample/Batch information (`BATCH_INFO`, for step 4-2)
    ```
    IID batch site
    A000000 b000_000_000 siteA
    B000000 b000_000_000 siteA
    C000000 b000_000_001 siteB
    D000000 b000_000_005 siteC
    ```
4. Sample list of Tzu Chi hospital in Hualien (`TZUCHI_HL_LIST`, for step 3-4)
    ```
    A000000
    B000000
    ```
5. List of sample current age (`age.list`, for step 5)
    ```
    A000000 A000000 40
    B000000 B000000 50
    C000000 C000000 65
    ```
6. List of sample sex (`sex.list`, for step 5)
    ```
    A000000 A000000 Female
    B000000 B000000 Female
    C000000 C000000 Male
    D000000 D000000 Female
    ```
7. Number of EMRs (Electronic Medical Records) for each sample (`emr_count.txt`, for step 5)
   
   This data prioritizes samples based on the number of EMRs they are associated with. Samples with a higher number of EMRs are weight. 
    ```
    FID IID COUNT
    A000000 A000000 177
    B000000 B000000 27
    C000000 C000000 102
    D000000 D000000 86
    ```
    
## 1. Initial QC by batch

### 1-1 QC by batch (01_qc_by_batch)
  * Remove SNPs with missing rate > 10%
  * Remove individuals with missing rate > 10%
  * Remove SNPs with missing rate > 5%
```
./01_exe.sh {BFILE_LIST}
./report.sh {BATCH_ID_LIST} ### optional
```
### 1-2 Missing rate difference between batches (02_snp_missing_diff)
Identify SNPs with the largest difference in missing rate > 0.02 between any two batches.
```
./02_exe.sh {BATCH_ID_LIST}
```
### 1-3 Allele frequency difference between batches (03_snp_freq)
Identify SNPs with difference in allele frequency > 0.1 between any two batches.

```
./03_exe_freq.sh {BATCH_ID_LIST}
```
## 2. Merge batches and basic QC
### 2-1 Merge (04_merge)
Merge batches from step 1-1 QC, then remove SNPs identified in step 1-2 and step 1-3.

```
./04_exe_uniq.sh
```
### 2-2 QC after merge (05_merge_qc)
  * Remove TPMI special SNPs (`tpm.remove.affy.list`)
  * Remove duplicated SNPs
  * Remove individuals with missing rate > 5%
  * Remove SNPs with missing rate > 2%

This step also generates common SNPs required for PCA.

```
./05_exe.sh ../tpm.remove.affy.list
```
## 3. Population assignment
The aim of this step is to identify the Han Chinese population.

Utilizing data from the 1000 Genomes Project and SGDP, we first identify the EAS (East Asian) population using PCA, and then further distinguish the Han Chinese group using Admixture.
### 3-1 PCA (06_pca)
Run PCA using SNPs that are common across 1000 Genomes Projects, SGDP and TPMI data.
```
./06_exe.sh {ONEKG_BFILE} {SGDP_BFILE}
```
### 3-2 PCAiR (07_eas_pcair)
Identify EAS based on PCA results, then QC and run PCAiR to calculate PCs for the EAS group.
  * Remove SNPs with missing rate > 2%
  * Remove SNPs with MAF (Minor Allele Frequency) < 0.01
```
./07_exe.sh {HIGH_LD_REGION_BED}
```
### 3-3 Admixture
This part includes 3 steps: establishing a reference, projection and assignment.

### 3-3-1 Reference (08_admixture/ref)
1. Select 2,594 samples from the 1000 Genomes Project and a random set of 3,000 TPMI samples to perform Admixture.
2. Identify samples exceeding threshold scores in any population (repeated 5 times):
   * TPM1: > 0.7
   * TPM2: > 0.65
```
./08_exe.sh {IGSR_SAMPLE_LIST} {TZUCHI_HL_LIST}
```
3. Combine samples from previous step and perform Admixture again.
```
cd refQ
./08_exe_refQ.sh {SGDP_SAMPLE_LIST}
```
The output file (*.P) is used as the reference panel for projection.
### 3-3-2 Projection (08_admixture/project_eas)
Project remaining samples onto the reference to obtain their scores in each population group. Assign samples to the population with the highest score if it exceeds 0.4 and is at least 0.1 higher than the second-highest score.
```
./08_exe_project.sh
```

## 4. QC within Han

###  4-1 QC (09_qc_within_han)
1. Select samples assigned to the Han Chinese population.
2. Basic QC:
    * Remove SNPs with missing rate > 2%
    * Remove SNPs with MAF < 0.01
3. Sex check:
    * Remove samples that fail plink --check-sex test.
    * Remove samples with gender data contradictory to the EMR provided gender
4. Heterozygosity check (F Coefficient):
    * Exclude samples with F score > 0.2 or < -0.2
5. Remove SNPs with MAF < 0.01
6. Retain only SNPs on autosome
7. Remove SNPs that fail HWE test (P-value < 1e-6)
``` 
./09_exe.sh
```

###  4-2 Batch GWAS (10_batch_gwas)
Perform GWAS on pairs of batches and remove significant SNPs to shrink the batch effects. 

Prepare covariates file necessary for GWAS execution.
1. Generate phenotype file `run.all.txt`.
```
./table.py {BATCH_INFO}
 ```
2. Run PCA: Obtain Principal Components (PCs).
```
./runPCAir_afterHanQC.sh
```
3. Create `pheno.txt`: merge phenotype, sex and PCs.
```
IID SEX PCAiR1  PCAiR2  PCAiR3  PCAiR4  PCAiR5  PCAiR6  PCAiR7  PCAiR8  PCAiR9  PCAiR10 Batch_001vsBatch_002    Batch_001vsBatch_003
```
Perform GWAS analysis to identify significant SNPs (p-value < 5e-8).
```
./runSAIGE.sh
```
Remove all significant SNPs, then run PCA and PCRelate. This step generates PCs and associations between samples, which will be used to identify the max unrelated set and reconstruct family pedigree.
```
./runPCAir_PCRelate_afterSAIGE.sh
```
> [!NOTE]
> If running out of memory, consider dividing the samples for execution. For details, refer to [this guide](https://github.com/UW-GAC/analysis_pipeline/tree/master#relatedness-and-population-structure).

## 5.Pedigree Reconstruction and Maximum Unrelated Set (11_PRIMUS)
Establishing the maximum unrelated set and pedigree reconstruction.

**1. Max unrelated set**   

Run PRIMUS (related samples only)
```sh
perl PRIMUS_v1.9.0/bin/run_PRIMUS.pl -i FILE=../10_batch_gwas/tpm1.han.afterQC.rmbatcheffects_pcrelate_forPRIMUS.txt IBD0=5 IBD1=6 IBD2=7 PI_HAT=8 --no_PR --high_qtrait emr_count.txt --degree_rel_cutoff 3 -o imus_3degree
```
Combine PRIMUS results with unrelated samples to form the maximum unrelated set.
```sh
grep -w -v -f <(cut -f1,3 ../10_batch_gwas/tpm1.han.afterQC.rmbatcheffects_pcrelate_forPRIMUS.txt |tr '\t' '\n'|sort | uniq) ../09_qc_within_han/han_geno002_maf001_checksex_het_maf001.autosome.hwe6.fam |cut -d' ' -f1 > not_in_primus.id
cat not_in_primus.id imus_3degree/tpm1.han.afterQC.rmbatcheffects_pcrelate_forPRIMUS.txt_maximum_independent_set |grep -v IID| sed 's/\t//g' | sort > maximum_independent_set.3_degree.id
```
**2. Pedigree reconstruction**

Run PRIMUS (related samples only)
```sh
perl PRIMUS_v1.9.0/bin/run_PRIMUS.pl -i FILE=../10_batch_gwas/tpm1.han.afterQC.rmbatcheffects_pcrelate_forPRIMUS.txt IBD0=5 IBD1=6 IBD2=7 PI_HAT=8 --no_IMUS --age_file age.list --sexes FILE=sex.list SEX=3 MALE=Male FEMALE=Female --degree_rel_cutoff 3 -o tpm1_han_PR_3degre
```

**3. Remove Duplicates**

Find duplicate pairs (PI_HAT > 0.9) and check with following rule:
1. Different birthday or gender: Remove both (possibly sample misplacement).
2. Same gender and birth:
   * Different hospitals: Keep one (preferably the one with more medical records).
   * Same hospitals: Keep both if the number of medical records is different (considered as twins). If the number of medical records is the same, manually confirm whether they are twins or the same individual.
3. Prioritize retaining samples with medical record data.
4. Pairs that cannot be confirmed are both retained.
5. For known duplicates, prioritize keeping the genotype from the TPM2 array.
