<!-- dx-header -->
# Variant Profiling
variant_profiling

Microsatallite Stability and Tumor/Normal Pair Comparison

Uses
- Docker Container [goalconsortium/vcfannot](https://hub.docker.com/repository/docker/goalconsortium/vcfannot/general)
- Git Repo [SCHOOL](https://github.com/bcantarel/school)

## I/O

**Input**
- Tumor Sample Sorted BAM
- Normal Sample Sorted BAM
- Reference Tar Gz file with NGSCheckMate.bed, MSI Sensor List Files
- Panel Tar Gz with Target Panel Bed
- SampleName/ReadGroup

**Output**
- NGS Checkmate Output files
- MSI Sensor Pro Output files

## Reference Files

**Assembly Reference**

- [NGSCheckMate Bed File](https://github.com/parklab/NGSCheckMate/tree/master/SNP)
- Reference Genome

```
mkdir references
cp GRCh38.fa references/genome.fa
cp SNP_GRCh38_hg38_wChr.bed NGSCheckMate.bed 
tar cfz ref.tar.gz references
```

**Panel Reference**
- Target Panel Bed
- MSI Baseline
  - Run Panel of Normal BAMs with Target Bed using APP  msisensor_createpanelref

```
tar xvf msiref.tar.gz
rm msiref.tar.gz
tar cfz panel.tar.gz microsatellites.list* targetpanel.bed
```


- Reference Files