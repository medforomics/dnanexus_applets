<!-- dx-header -->
# RNASeq Align
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
