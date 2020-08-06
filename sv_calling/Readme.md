<!-- dx-header -->
# Structural Variant Calling
sv_calling

Uses
- Docker Container [goalconsortium/structuralvariant](https://hub.docker.com/repository/docker/goalconsortium/structuralvariant/general)
- Git Repo [SCHOOL](https://github.com/bcantarel/school)

Options
- pindel: PINDEL
- delly: DELLY 
- svaba: SVABA
- cnvkit: CNVKit
- itdseek: ITDSeek

**Input**
- Tumor Sample Sorted BAM
- Normal Sample Sorted BAM
- Reference Tar Gz file with NGSCheckMate.bed, MSI Sensor List Files
- Panel Tar Gz with Target Panel Bed
- SampleName/ReadGroup
- Algo: pindel delly svaba cnvkit itdseek

**Output**
- SV VCF Files (Tar Gz)
- CNVKit Output Files (Tar Gz)
- Parsed Gene Fusion Files (Tar Gz)
