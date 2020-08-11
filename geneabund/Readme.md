<!-- dx-header -->
# # Gene Abundance Calculation
geneabund

Runs Feature Count and String Tie to determine raw read counts and FPKM of genes.

Uses
- Docker Container [goalconsortium/structuralvariant](https://hub.docker.com/repository/docker/goalconsortium/geneabund/general)
- Git Repo [SCHOOL](https://github.com/bcantarel/school)

**Input**
- Sorted BAM
- Gene GTF
- ReadGroup/SampleName
- Gene List (for panel data)
- Stranded (for specialty assays that generate stranded libraries)

**Output**
- Raw Count Table
- FPKM Table
- StringTie Output file
