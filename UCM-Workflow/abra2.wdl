version 1.0

## Maintainer: Pankhuri Wanjari
## Contact: pwanjari@bsd.uchicago.edu

workflow abra2_realignment{
    input {
        String docker_image
        String? sample_name
        File InputBAM
        File InputBAMBai
        File genome_index_tgz
        File genesBED
    }

    call abra2{
        input:
        BWA_reference_tgz = genome_index_tgz,
        docker_image = docker_image,
        sample_name = sample_name,
        InputBAM = InputBAM,
        InputBAMBai = InputBAMBai,
        genes_200bp = genesBED
    }
    
    output {
        File OutputABRABAM = abra2.OutputABRABAM
        File OutputABRABAI = abra2.OutputABRABAI
        File OutputAbraNoDupsBAM = abra2.OutputAbraNoDupsBAM
        File OutputAbraNoDupsBAI = abra2.OutputAbraNoDupsBAI
        File outMetrics = abra2.outMetrics
    }

}

task abra2 {
    input {
        File BWA_reference_tgz
        File InputBAM
        File InputBAMBai
        File genes_200bp
        String docker_image
        String? sample_name
        Int p = 6
        Int MNF = 5
        Int MBQ = 150
        Float MER = 0.05
    }

    String genome_basename = basename(BWA_reference_tgz, ".tar.gz")
    String sampleName = select_first([sample_name, basename(InputBAM, ".bam")])

    command <<<
        set -uexo pipefail

        tar xzvf ~{BWA_reference_tgz}

        java -Xmx50G -jar /usr/local/bin/abra2-2.18.jar \
        --in ~{InputBAM} \
        --out ~{sampleName}.abraPass1.bam \
        --ref ~{genome_basename}.fa \
        --targets ~{genes_200bp} \
        --threads ~{p} \
        --mnf ~{MNF} --mbq ~{MBQ} --mer ~{MER}

        #  Sort the BAM file by coordinate
        java -Xmx30g -jar /usr/local/bin/picard.jar SortSam \
        SO=coordinate \
        INPUT=~{sampleName}.abraPass1.bam \
        OUTPUT=~{sampleName}.abraPass1.sorted.bam \
        CREATE_INDEX=true

        # Run PICARD Mark Duplicates
        java -Xmx20g -jar /usr/local/bin/picard.jar MarkDuplicates \
        INPUT=~{sampleName}.abraPass1.sorted.bam \
        OUTPUT=~{sampleName}.abraPass1.sorted.noDups.bam \
        ASSUME_SORT_ORDER=coordinate \
        METRICS_FILE=~{sampleName}.duplicates.metrics \
        REMOVE_DUPLICATES=true

        samtools index ~{sampleName}.abraPass1.sorted.noDups.bam
        rm ~{sampleName}.abraPass1.bam

    >>>

    runtime {
        docker: docker_image
    }

    output {
        File OutputABRABAM = "~{sampleName}.abraPass1.sorted.bam"
        File OutputABRABAI = "~{sampleName}.abraPass1.sorted.bai"
        File OutputAbraNoDupsBAM = "~{sampleName}.abraPass1.sorted.noDups.bam"
        File OutputAbraNoDupsBAI = "~{sampleName}.abraPass1.sorted.noDups.bam.bai"
        File outMetrics = "~{sampleName}.duplicates.metrics"
    }
}
