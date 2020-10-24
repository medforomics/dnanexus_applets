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

## I/O

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

## Reference Databases

**Assembly-Based Reference**

```
mkdir reference
my GRCh38.fa reference/genome.fa
cd reference
java -jar picard.jar CreateSequenceDictionary R=genome.fa O=genome.dict
samtools faidx genome.fa
cut -f 1,2 genome.fa.fai > genomefile.txt
fasta_generate_regions.py genome.fa.fai 5000000 > genomefile.5M.txt
```

- PlatRef.header
```
echo '##INFO=<ID=PlatRef,Number=1,Type=String,Description="Validation by Platinum Genome Project">' > PlatRef.header
```
- RepeatType.header
```
echo '##INFO=<ID=RepeatType,Number=1,Type=String,Description="Repeat type as defined by the rmsk and simpleRepeat files from UCSC">' > RepeatType.header
```

- oncokb_hotspot.header
```
echo '##INFO=<ID=OncoKB_AF,Number=1,Type=String,Description="AF in OncoKB">' > oncokb_hotspot.header
echo '##INFO=<ID=OncoKB_REF,Number=1,Type=String,Description="OncoKB REF">' >> oncokb_hotspot.header
echo '##INFO=<ID=OncoKB_ALT,Number=1,Type=String,Description="OncoKB ALT">' >> oncokb_hotspot.header
echo '##INFO=<ID=Gene,Number=1,Type=String,Description="Hugo Gene Symbol">' >> oncokb_hotspot.header
echo '##INFO=<ID=OncoKB_ProteinChange,Number=1,Type=String,Description="Amino Acid Effect">' >> oncokb_hotspot.header
echo '##INFO=<ID=OncoKB_AF,Number=1,Type=String,Description="AF in OncoKB">' >> oncokb_hotspot.header
echo '##INFO=<ID=OncoTree_Tissue,Number=1,Type=String,Description="Tissue Type">' >> oncokb_hotspot.header
echo '##INFO=<ID=OncoTree_MainType,Number=1,Type=String,Description="Oncotree Main Type">' >> oncokb_hotspot.header
echo '##INFO=<ID=OncoTree_Code,Number=1,Type=String,Description="Oncotree Code">' >> oncokb_hotspot.header
echo '##INFO=<ID=OncoKBHotspot,Number=1,Type=String,Description="Hotspot OncoKB">' >> oncokb_hotspot.header
```

- strelka.missing.header
```
echo '##INFO=<ID=QSI,Number=1,Type=Integer,Description="Quality score for any somatic variant, ie. for the ALT haplotype to be present at a significantly different frequency in the tumor and normal">' > strelka.missing.header
echo '##INFO=<ID=TQSI,Number=1,Type=Integer,Description="Data tier used to compute QSI">' >> strelka.missing.header
echo '##INFO=<ID=NT,Number=1,Type=String,Description="Genotype of the normal in all data tiers, as used to classify somatic variants. One of {ref,het,hom,conflict}.">' >> strelka.missing.header
echo '##INFO=<ID=QSI_NT,Number=1,Type=Integer,Description="Quality score reflecting the joint probability of a somatic variant and NT">' >> strelka.missing.header
echo '##INFO=<ID=TQSI_NT,Number=1,Type=Integer,Description="Data tier used to compute QSI_NT">' >> strelka.missing.header
echo '##INFO=<ID=SNVSB,Description="Sample SNV strand bias value (SB)">' >> strelka.missing.header\
echo '##INFO=<ID=ReadPosRankSum,Number=1,Type=Float,Description="Z-score from Wilcoxon rank sum test of Alt vs. Ref read position bias">' >> strelka.missing.header
echo '##INFO=<ID=DP,Number=1,Type=Integer,Description="Approximate read depth; some reads may have been filtered">' >> strelka.missing.header
echo '##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">' >> strelka.missing.header
```
- gnomad.header
```
echo '##INFO=<ID=AF_POPMAX,Number=A,Type=Float,Description="Maximum Allele Frequency across populations (excluding OTH) in GnomAD in genomes">' > gnomad.header
echo '##INFO=<ID=GNOMAD_AF,Number=A,Type=Float,Description="AC in the GnomAD population">' >> gnomad.header
echo '##INFO=<ID=GNOMAD_HOM,Number=A,Type=Integer,Description="Count of homozygous individuals">' >> gnomad.header
echo '##INFO=<ID=GNOMAD_HG19_VARIANT,Number=.,Type=String,Description="Coordinates for HG19, for creating links to GNOMAD website">' >> gnomad.header
echo '##INFO=<ID=QSS,Number=1,Type=Integer,Description="Quality score for any somatic variant, ie. for the ALT haplotype to be present at a significantly different frequency in the tumor and normal">' >> gnomad.header
echo '##INFO=<ID=TQSS,Number=1,Type=Integer,Description="Data tier used to compute QSI">' >> gnomad.header
echo '##INFO=<ID=NT,Number=1,Type=String,Description="Genotype of the normal in all data tiers, as used to classify somatic variants. One of {ref,het,hom,conflict}.">' >> gnomad.header
echo '##INFO=<ID=QSS_NT,Number=1,Type=Integer,Description="Quality score reflecting the joint probability of a somatic variant and NT">' >> gnomad.header
echo '##INFO=<ID=TQSS_NT,Number=1,Type=Integer,Description="Data tier used to compute QSI_NT">' >> gnomad.header
echo '##INFO=<ID=SNVSB,Number=.,Type=String,Description="Sample SNV strand bias value (SB)">' >> gnomad.header
echo '##INFO=<ID=ReadPosRankSum,Number=1,Type=Float,Description="Z-score from Wilcoxon rank sum test of Alt vs. Ref read position bias">' >> gnomad.header
echo '##INFO=<ID=DP,Number=1,Type=Integer,Description="Approximate read depth; some reads may have been filtered">' >> gnomad.header
echo '##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">' >> gnomad.header
```

- [dbNSFP](https://pcingola.github.io/SnpEff/ss_dbnsfp/}
```
wget https://snpeff.blob.core.windows.net/databases/dbs/GRCh37/dbNSFP_4.1a/dbNSFP4.1a.txt.gz
wget https://snpeff.blob.core.windows.net/databases/dbs/GRCh37/dbNSFP_4.1a/dbNSFP4.1a.txt.gz.tbi
mv dbNSFP4.1a.txt.gz dbNSFP.txt.gz
mv dbNSFP4.1a.txt.gz.tbi dbNSFP.txt.gz.tbi
```

- [ClinVar](https://ftp.ncbi.nlm.nih.gov/pub/clinvar)
```
wget https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh38/clinvar.vcf.gz
wget https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh38/clinvar.vcf.gz.tbi
```

- [dbSNP](https://ftp.ncbi.nih.gov/snp)
```
wget https://ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/00-All.vcf.gz
wget https://ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/00-All.vcf.gz.tbi
mv 00-All.vcf.gz dbSnp.vcf.gz
mv 00-All.vcf.gz.tbi dbSnp.vcf.gz.tbi
```

- [COSMIC](https://cancer.sanger.ac.uk/cosmic/download)
  - [See Scripted Instructions for Download](https://cancer.sanger.ac.uk/cosmic/file_download_info?data=GRCh38%2Fcosmic%2Fv92%2FVCF%2FCosmicCodingMuts.vcf.gz)
  - Download VCF/CosmicCodingMuts.vcf.gz
  - Download VCF/CosmicNonCodingVariants.vcf.gz
  - Use VCFTools to form final file
```
vcf-concat CosmicCodingMuts.vcf.gz CosmicNonCodingVariants.vcf.gz |vcf-sort > cosmic.vcf.gz
tabix cosmic.vcf.gz
```

- [GNOMAD](https://gnomad.broadinstitute.org/downloads)


- cytoBand.txt
```
wget http://hgdownload.cse.ucsc.edu/goldenpath/hg38/database/cytoBand.txt.gz
gunzip cytoBand.txt.gz
```

- oncokb hotspot
  - See [Download Page](https://www.oncokb.org/apiAccess)
  - oncokb_hotspot.txt.gz
      - tabix to create oncokb_hotspot.txt.gz.tbi
  - extracted form VCF with the following header
    - CHROM
    - FROM
    - TO
    - OncoKB_REF
    - OncoKB_ALT
    - Gene
    - OncoKB_ProteinChange
    - OncoKB_AFOncoTree_Tissue
    - OncoTree_MainType
    - OncoTree_Code
    - OncoKBHotspot

- GnomAD
  - See [Download Page](https://gnomad.broadinstitute.org/downloads)
  - gnomad.txt.gz
    - tabix to create gnomad.txt.gz.tbi
  - extracted form VCF with the following header
    - CHROM
    - POS
    - REF
    - ALT
    - GNOMAD_HOM
    - GNOMAD_AF
    - AF_POPMAX
    - GNOMAD_HG19_VARIANT

- Repeats  
  - Repeat Databases are available at http://hgdownload.cse.ucsc.edu/goldenpath/hg38/database
  - Database could include rmsk, simpleRepeat
  - in BED format called repeat_regions.bed.gz
  - use tabix to create index

**Panel Reference**
```
tar cfz panel.tar.gz targetpanel.bed
```
