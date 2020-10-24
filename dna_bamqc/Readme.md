<!-- dx-header -->
# DNA QC Stats

Concat stat txt files from alignment workflow

fastqc, coveragebed, samtools flagstat, picard EstimateLibraryComplexity

## I/O

**Input**
- Sorted BAM
- BAM BAI,
- Reference Tar Gz file with genome.fa, genome.fa.fai, genomefile.txt (bedtools)
- Panel Tar Gz with Target Panel Bed
- Stat File from Trim Galore App
- ReadGroup/SampleName 

**Output**
- Sequence Statistics Out Files (Tar Gz)


## Reference File Creation**

**Assembly Reference**
```
mkdir references
cp GRCh38.fa references/genome.fa
samtools faidx references/genome.fa
cut -f 1,2 references/genome.fa.fai > genomefile.txt
tar cfz ref.tar.gz references
```
**Panel Reference**
```
tar cfz panel.tar.gz targetpanel.bed
```
