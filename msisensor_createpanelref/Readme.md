<!-- dx-header -->
# MSI Panel Reference File Generator
msisensor_createpanelref


This app will take a fastA file and a set of panel of normals BAMs to generate reference files for running MSISensor-Pro with a tumor only family when a match normal is not available.

Uses
- Docker Container [goalconsortium/vcfannot](https://hub.docker.com/repository/docker/goalconsortium/vcfannot/general)
- Git Repo [SCHOOL](https://github.com/bcantarel/school)


## I/O
**Input**

- Panel of Normal Samples Sorted BAM Files

**Output**

- MSI Sensor Baseline File

## Reference Files

**Assembly Reference**

- Reference Genome

```
mkdir references
cp GRCh38.fa references/genome.fa
tar cfz ref.tar.gz references
```