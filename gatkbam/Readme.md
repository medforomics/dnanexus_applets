<!-- dx-header -->
# GATK BQSR
gatkbam

Uses
- Docker Container [goalconsortium/variantcalling](https://hub.docker.com/repository/docker/goalconsortium/variantcalling/general)
- Git Repo [SCHOOL](https://github.com/bcantarel/school)


Runs BaseRecalibrator and ApplyBQSR on BAM to create BAM for MuTect2

*Input**
- Tumor Sample Sorted BAM
- Reference Tar Gz file with genome.fa and files for annotation
  - genome.fa
  - dbSNP
- SampleName/ReadGroup

**Output**
- GATK BAM

## Reference Databases

**Assembly-Based Reference**

- Reference Assembly
```
mkdir reference
my GRCh38.fa reference/genome.fa
```

- [dbSNP](https://ftp.ncbi.nih.gov/snp)
```
wget https://ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/00-All.vcf.gz
wget https://ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/00-All.vcf.gz.tbi
mv 00-All.vcf.gz dbSnp.vcf.gz
mv 00-All.vcf.gz.tbi dbSnp.vcf.gz.tbi
```
Create Tar Gz File
```
tar cfz ref.tar.gz reference
```
