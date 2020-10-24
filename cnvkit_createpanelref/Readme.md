<!-- dx-header -->
# CNVKit Panel Reference File Generator

This app will take a bed file and a set of panel of normals BAMs to generate reference files for running CNVkit


Uses
- Docker Container [goalconsortium/vcfannot](https://hub.docker.com/repository/docker/goalconsortium/vcfannot/general)
- Git Repo [SCHOOL](https://github.com/bcantarel/school)


## I/O
**Input**

- Panel of Normal Samples Sorted BAM Files
- Target Panel Bed File
- Reference Tar Gz

**Output**

- CNVKit Panel of Normal Correction Reference File

## Reference Files

**Assembly Reference**

- Reference Genome
- Reference Annotation File
  - [hg38 annotation reference](http://hgdownload.soe.ucsc.edu/goldenPath/hg38/database/refFlat.txt.gz)
  - [hg19 annotation reference](http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/refFlat.txt.gz)

```
mkdir references
cp GRCh38.fa references/genome.fa
cp refFlat.txt.gz reference
gunzip reference/refFlat.txt.gz
tar cfz ref.tar.gz references
```

**Panel Reference**
```
tar cfz panel.tar.gz targetpanel.bed
```
