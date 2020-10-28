<!-- dx-header -->
# RNA BAM QC
rna_bamqc

positional read count and metrics of bam file

Uses
- Docker Container [goalconsortium/structuralvariant](https://hub.docker.com/repository/docker/goalconsortium/alignment/general)
- Git Repo [SCHOOL](https://github.com/bcantarel/school)

## I/O

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

## Reference File Generation

**Assembly Reference**
```
mkdir references
cp GRCh38.fa references/genome.fa
tar cfz ref.tar.gz references
```
**Panel Reference**
```
tar cfz panel.tar.gz targetpanel.bed
```



