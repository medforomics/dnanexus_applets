<!-- dx-header -->
# Generate BAM: BWA + MarkDuplicates + QC (DNAnexus Platform App)

This is the source code for an app that runs on the DNAnexus Platform.
For more information about how to run or modify it, see
https://wiki.dnanexus.com/.

# Align_Markdups

This app runs:
- BWA against the Human Genome
- BWA against the Viral Genom
- MarkDupliates
  - samtools markdup
  - picard MarkDuplicates
  - picard MarkDuplicates BARCODE_TAG=RX 
  - fgbio GroupReadsByUmi, CallMolecularConsensusReads 
- QC
  - samtools flagstat
  - fastqc
  - bedtools coverage
  - picard EstimateLibraryComplexity

**Runs with:**
- Docker Container [goalconsortium/alignment](https://hub.docker.com/repository/docker/goalconsortium/alignment/general)
- Git Repo [SCHOOL](https://github.com/bcantarel/school)

**Required Input:**
- Fastq Files (PE):
  - fq1
  - fq2
- Human Ref: BWA Index Files for the Human Genome
- Virus Ref: BWA Index Files for the Virus Genome
- Panel File: BED file
- TrimStat Fle: Trim Report output from TrimGalore
- PairID: SampleName/ReadGroup
- MarkDup Method
  - samtools
  - picard
  - picard_umi
  - fgbio_umi

**Output:**
- Raw BAM
- BAM post mark duplicates step
- Viral Alignment Stats
- Alignment Stat Files
