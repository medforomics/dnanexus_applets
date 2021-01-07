<!-- dx-header -->
# DNA Alignment (dalign)

- BWA against the Human Genome

Uses
- [docker.io/goalconsortium/alignment:0.5.40]((https://hub.docker.com/repository/docker/goalconsortium/alignment/general)
   - bwa 0.7.17
   - fgbio 1.1.0
   - picard 2.21.7
- [SCHOOL](https://github.com/bcantarel/school.git)

**Input**
- Fastq Files (PE):
- Human Ref: BWA Index Files for the Human Genome
- Design File
  - Tab-Delimted with Columns: SampleID, FqR1, FqR2.  Include these column names in the first row. SampleID is a unique ID per Pair of Reads.  FqR1 is the R1 of the read pair and FqR2 is the R2 of the read pair.

| SampleID | FqR1 | FqR2 |
|---|---|---|
| Sample1 | Sample1_L001_001_R1.fastq.gz | Sample1_L001_001_R2.fastq.gz  |
| Sample2 | Sample2_L001_001_R1.fastq.gz | Sample2_L001_001_R2.fastq.gz  |
| Sample3 | Sample3_L001_001_R1.fastq.gz | Sample3_L001_001_R2.fastq.gz  |
| Sample4 | Sample4_L001_001_R1.fastq.gz | Sample4_L001_001_R2.fastq.gz  |
| Sample5 | Sample5_L001_001_R1.fastq.gz | Sample5_L001_001_R2.fastq.gz  |
| Sample6 | Sample6_L001_001_R1.fastq.gz | Sample6_L001_001_R2.fastq.gz  |

**Output**
- Sorted Human Ref BAM, BAI

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
