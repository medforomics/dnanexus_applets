# dnanexus_applets

## Trim Galore
trim_galore

*Trim Galore: Trims poor quality sequence from read*


Uses
- [docker.io/goalconsortium/trim_galore:0.5.40](https://hub.docker.com/repository/docker/goalconsortium/trim_galore/general)
  - trim_galore_v0.4.1
  - cutadapt==1.9.1
- [SCHOOL](https://github.com/bcantarel/school.git)

**Input**
- Fastq Files (PE):
  - fq1
  - fq2
- Output Prefix Name

**Output**
- Fastq Files (PE):
  - fq1
  - fq2

## DNA Alignment (dalign)

- BWA against the Human Genome
- BWA against the Viral Genom

Uses
- [docker.io/goalconsortium/alignment:0.5.40]((https://hub.docker.com/repository/docker/goalconsortium/alignment/general)
   - bwa 0.7.17
   - fgbio 1.1.0
   - picard 2.21.7
- [SCHOOL](https://github.com/bcantarel/school.git)

**Input**
- Fastq Files (PE):
  - fq1
  - fq2
- Human Ref: BWA Index Files for the Human Genome
- Virus Ref: BWA Index Files for the Virus Genome (optional)
- ReadGroup/SampleName 

**Output**
- Sorted Human Ref BAM, BAI
- Viral alignment stats (optional)

## ABRA2
abra2

Uses
- [docker.io/goalconsortium/abra2:0.5.40](https://hub.docker.com/repository/docker/goalconsortium/abra/general)
  - ABRA 2.20
  - samtools 1.10

**Input**
- Tumor BAM File
- Normal BAM File
- Reference Tar Gz file with genome.fa
- Panel Tar Gz with Target Panel Bed
- ReadGroup/SampleName

**Output**
- ABRA2 Tumor BAM
- ABRA2 Normal BAM
- ABRA2 Tumor BAM BAI
- ABRA2 Normal BAM BAI

## DNA QC Stats
dna_bamqc

fastqc, coveragebed, samtools flagstat, picard EstimateLibraryComplexity

Uses
- Docker Container [goalconsortium/vcfannot](https://hub.docker.com/repository/docker/goalconsortium/vcfannot/general)
- [SCHOOL](https://github.com/bcantarel/school.git)

**Input**
- Sorted BAM
- BAM BAI,
- Reference Tar Gz file with genome.fa, genome.fa.fai, genomefile.txt (bedtools)
- Panel Tar Gz with Target Panel Bed
- Stat File from Trim Galore App
- ReadGroup/SampleName 

**Output**
- Sequence Statistics Out Files (Tar Gz)

## Mark Duplicates
markdups

Options
- samtools markdup
- picard Picard MarkDuplicates
- picard_umi Picard MarkDuplicates BARCODE_TAG=RX 
- fgbio_umi GroupReadsByUmi, CallMolecularConsensusReads 

Uses
- Docker Container [goalconsortium/alignment](https://hub.docker.com/repository/docker/goalconsortium/alignment/general)
- Git Repo [SCHOOL](https://github.com/bcantarel/school)

**Input**
- Sorted BAM
- BAM BAI,
- PairID: SampleName/ReadGroup
- MarkDup Method
  - samtools
  - picard
  - picard_umi
  - fgbio_umi
- Human Ref: BWA Index Files for the Human Genome (used with fgbio_umi)

**Output**
- Sorted BAM
- BAM BAI,
- PairID: SampleName/ReadGroup

## GATK BQSR
gatkbam

Uses
- Docker Container [goalconsortium/gatk](https://hub.docker.com/repository/docker/goalconsortium/gatk/general)
- Git Repo [SCHOOL](https://github.com/bcantarel/school)

**Input**
- Sorted BAM
- BAM BAI,
- PairID: SampleName/ReadGroup
- Reference Tar Gz file with genome.fa, genome.fa.fai

**Output**
- Sorted BAM
- BAM BAI,
- SampleName/ReadGroup

## Variant Profiling
variant_profiling

Microsatallite Stability and Tumor/Normal Pair Comparison

Uses
- Docker Container [goalconsortium/vcfannot](https://hub.docker.com/repository/docker/goalconsortium/vcfannot/general)
- Git Repo [SCHOOL](https://github.com/bcantarel/school)

**Input**
- Tumor Sample Sorted BAM
- Normal Sample Sorted BAM
- Reference Tar Gz file with NGSCheckMate.bed, MSI Sensor List Files
- Panel Tar Gz with Target Panel Bed
- SampleName/ReadGroup

**Output**
- NGS Checkmate Output files
- MSI Sensor Pro Output files

## Variant Calling (SNV/Indels) 
snv_indel_calling

Uses
- Docker Container [goalconsortium/variantcalling](https://hub.docker.com/repository/docker/goalconsortium/variantcalling/general)
- Git Repo [SCHOOL](https://github.com/bcantarel/school)

Options
- fb: FreeBayes
- platypus: Platypus
- strelka2: Strelka2
- mutect: MuTect2 (GATK4)
- shimmer: Shimmer

If multiple callers are provided space separated, will run multiple programs

**Input**
- Tumor Sample Sorted BAM
- Normal Sample Sorted BAM
- Reference Tar Gz file with genome.fa and files for annotation
  - gnomad.txt.gz
  - oncokb_hotspot.txt.gz
  - repeat_regions.bed.gz
  - dbSnp.vcf.gz
  - clinvar.vcf.gz
  - cosmic.vcf.gz
  - dbNSFP.txt.gz
  
- Panel Tar Gz with Target Panel Bed
- SampleName/ReadGroup
- Algo: fb platypus strelka2 mutect2 shimmer

**Output**
- Annotated Normalized VCF
- Original VCF

## Structural Variant Calling
sv_calling

Uses
- Docker Container [goalconsortium/structuralvariant](https://hub.docker.com/repository/docker/goalconsortium/structuralvariant/general)
- Git Repo [SCHOOL](https://github.com/bcantarel/school)

Options
- pindel: PINDEL
- pindel_itd: PINDEL restricted to itd_genes.bed
- delly: DELLY 
- svaba: SVABA
- cnvkit: CNVKit
- itdseek: ITDSeek

**Input**
- Tumor Sample Sorted BAM
- Normal Sample Sorted BAM
- Reference Tar Gz file with NGSCheckMate.bed, MSI Sensor List Files
- Panel Tar Gz with Target Panel Bed
- SampleName/ReadGroup
- Algo: pindel delly svaba cnvkit itdseek

**Output**
- SV VCF Files (Tar Gz)
- CNVKit Output Files (Tar Gz)
- Parsed Gene Fusion Files (Tar Gz)

## Intergrate VCF VCF
integratevcf

Create a Union VCF File

Uses
- Docker Container [goalconsortium/structuralvariant](https://hub.docker.com/repository/docker/goalconsortium/structuralvariant/general)
- Git Repo [SCHOOL](https://github.com/bcantarel/school)

**Input**
- VCF Files (Tar Gz) (Array)
- Genome.dict - Genome Dictionary File

**Output**
- Union VCF


## RNASeq Align
rnaalign

Aligns RNASeq Data to a reference genome with HiSAT2

Uses
- Docker Container [goalconsortium/structuralvariant](https://hub.docker.com/repository/docker/goalconsortium/structuralvariant/general)
- Git Repo [SCHOOL](https://github.com/bcantarel/school)

**Input**
- Fastq Files (PE):
  - fq1
  - fq2
- Human Ref: HiSAT2 Index Files for the Human Genome
- ReadGroup/SampleName 

**Output**
- Sorted Human Ref BAM, BAI
- Alignment Stats File from HiSAT

## RNA BAM QC
rna_bamqc

Uses
- Docker Container [goalconsortium/structuralvariant](https://hub.docker.com/repository/docker/goalconsortium/alignment/general)
- Git Repo [SCHOOL](https://github.com/bcantarel/school)

 **Input**
- Sorted Human Ref BAM, BAI
- Alignment Stats File from HiSAT
- ReadGroup/SampleName 
- Panel Tar Gz with Target Panel Bed (optional to run BAM Read Count)

**Output**

- BAM Read Count
- Output from FASTQC
- HTML File from FastQC
- TXT file with Summary of QC Metrics

## Gene Abundance Calculation
geneabund

Runs Feature Count and String Tie to determine raw read counts and FPKM of genes.

Uses
- Docker Container [goalconsortium/structuralvariant](https://hub.docker.com/repository/docker/goalconsortium/geneabund/general)
- Git Repo [SCHOOL](https://github.com/bcantarel/school)

**Input**
- Sorted BAM
- Gene GTF
- ReadGroup/SampleName
- Gene List (for panel data)
- Stranded (for specialty assays that generate stranded libraries)

**Output**
- Raw Count Table
- FPKM Table
- StringTie Output file

## Gene Fusion Detection
star_fusion

Runs Star Fusion to Detect Gene Fusions and uses AGFusion to annotate Exon Junctions.

**Input**
- Fastq Files (PE):
  - fq1
  - fq2
- Human Ref: (CTAT plug and play)[https://github.com/FusionAnnotator/CTAT_HumanFusionLib/wiki]
- ReadGroup/SampleName 

**Output**
- Star Fusion Output and Derived Files
