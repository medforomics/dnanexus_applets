<!-- dx-header -->
# Structural Variant Calling
sv_calling

Uses
- Docker Container [goalconsortium/structuralvariant](https://hub.docker.com/repository/docker/goalconsortium/structuralvariant/general)
- Git Repo [SCHOOL](https://github.com/bcantarel/school)

Options
- pindel: PINDEL
- pindel_itd:
  - PINDEL restricted to regions in itd_genes.bed
- delly: DELLY 
- svaba: SVABA
- cnvkit: CNVKit
- itdseek: ITDSeek

## I/O

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


## Reference Databases

**Assembly-Based Reference**

- Reference Genome
- PINDEL Gene File if pindel_itd  

```
mkdir reference
my GRCh38.fa reference/genome.fa
cd reference
java -jar picard.jar CreateSequenceDictionary R=genome.fa O=genome.dict
samtools faidx genome.fa
cut -f 1,2 genome.fa.fai > genomefile.txt
fasta_generate_regions.py genome.fa.fai 5000000 > genomefile.5M.txt
pindel_genes.bed
cd ..
tar cfz ref.tar.gz reference
```

**Panel Reference**

- Target Panel Bed
- CNVKit
  - Target Bed
  - Antitarget Bed
  - Panel of Normals CNN File

```
tar cfz panel.tar.gz cnvkit.targets.bed cnvkit.antitargets.bed pon.cnn targetpanel.bed
```


CVNKit Reference Files can be generated using the cnvkit_createpanelref app

PINDEL can be very slow -- if you just want to use PINDEL only for ITD detection, then you can create file with the positions of the relavent genes