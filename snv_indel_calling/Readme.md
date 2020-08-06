<!-- dx-header -->
# Variant Calling (SNV/Indels) 
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
