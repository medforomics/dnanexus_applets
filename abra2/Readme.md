<!-- dx-header -->
# ABRA2 (DNAnexus Platform App)

Uses
- docker container docker.io/goalconsortium/abra2:0.5.40
  - ABRA 2.20
  - samtools 1.10

Recommended hardware: mem1_ssd1_v2_x16
- 30GB memory
- 16 cores

Input
- Tumor BAM File
- Normal BAM File
- Reference Tar Gz file with genome.fa
- Panel Tar Gz with Target Panel Bed
- ReadGroup/SampleName

Output
- ABRA2 Tumor BAM
- ABRA2 Normal BAM
- ABRA2 Tumor BAM BAI
- ABRA2 Normal BAM BAI

