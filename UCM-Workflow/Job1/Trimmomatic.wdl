version 1.0

## Maintainer: Pankhuri Wanjari
## Contact: pwanjari@bsd.uchicago.edu

task trimmomatic {
    input {
        File FastqR1
        File FastqR2
        String sampleName
        String docker_image
    }

    command <<<
        set -e
        set -o pipefail

        echo -e "Fastq files are R1: ~{FastqR1}, R2: ~{FastqR2}. Sample name is ~{sampleName}"
        
        java -jar $TRIMMOMATIC \
        PE ~{FastqR1} ~{FastqR2} \
        ~{sampleName}_R1_001.trimmed.fastq \
        ~{sampleName}_R1_001.trimmed.unpaired.fastq \
        ~{sampleName}_R2_001.trimmed.fastq \
        ~{sampleName}_R2_001.trimmed.unpaired.fastq \
        ILLUMINACLIP:/usr/bin/Trimmomatic-0.36/adapters/TruSeq3-PE.fa:2:30:10:2:true
    >>>

    runtime {
        docker: docker_image
    }

    output {
        File trimmedFastqR1 = "~{sampleName}_R1_001.trimmed.fastq"
        File trimmedFastqR2 = "~{sampleName}_R2_001.trimmed.fastq"
        File trimmedUnpairedFastqR1 = "~{sampleName}_R1_001.trimmed.unpaired.fastq"
        File trimmedUnpairedFastqR2 = "~{sampleName}_R2_001.trimmed.unpaired.fastq"
    }

}
