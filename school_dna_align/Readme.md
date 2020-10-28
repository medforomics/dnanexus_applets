<!-- dx-header -->
# DNA Alignment (dalign)

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
- UMI
  - in the case that the fastqs were demultiplexed in a way that UMI sequences are in the sequence name, this option woudl a

**Output**
- Sorted Human Ref BAM, BAI
- Viral alignment stats (optional)

**Reference File Creation**

Human Ref:
```
mkdir humanref
cp GRCh38.fa humanref/genome.fa
cd humanref
bwa index -a bwtsw genome.fa
cd ..
tar cfz humanref.tar.gz humaref
```

Virus Ref:
```
mkdir virusref
cp GRCh38.fa virusref/genome.fa
cd virusref
bwa index -a bwtsw genome.fa
cd ..
tar cfz virusref.tar.gz humaref
```