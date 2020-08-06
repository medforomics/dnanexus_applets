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

**Output**
- Sorted Human Ref BAM, BAI
- Viral alignment stats (optional)
