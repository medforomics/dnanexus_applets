version 1.0

## Maintainer: Pankhuri Wanjari
## Contact: pwanjari@bsd.uchicago.edu

task bwa_mem {
    input {
        File BWA_reference_tgz
        String docker_image
        String sampleName
        File trimmedFastqR1
        File trimmedFastqR2
    }

    String genome_basename = basename(BWA_reference_tgz, ".tar.gz")

    command <<<
        set -uexo pipefail

        tar xzvf ~{BWA_reference_tgz}

        echo -e "Aligning data with BWAMEM. Trimmed Fastq's are: ~{trimmedFastqR1}, ~{trimmedFastqR2}"

        # Align the data with bwa mem
        bwa mem -M -t 6 -L 50,50 \
        ~{genome_basename}.fa \
        ~{trimmedFastqR1} ~{trimmedFastqR2} > ~{sampleName}.sam

        # Sort and convert to BAM and index
        java -Xmx30g -jar $PICARD AddOrReplaceReadGroups \
        INPUT=~{sampleName}.sam \
        OUTPUT=~{sampleName}.sorted.RG.bam \
        CREATE_INDEX=true \
        SORT_ORDER=coordinate \
        RGID=1 \
        RGLB=~{sampleName} \
        RGPU="HiSeq" \
        RGSM=~{sampleName} \
        RGCN="University of Chicago" \
        RGDS=GRCh37 \
        RGPL=illumina \
        VALIDATION_STRINGENCY=SILENT;

        # Delete the SAM File
        rm ~{sampleName}.sam

    >>>

    runtime {
        docker: docker_image
    }

    output {
        File bam = "~{sampleName}.sorted.RG.bam"
        File bam_bai = "~{sampleName}.sorted.RG.bai"
    }

}

task mapq0_filter {
    input {
        File BAMFile
        File BAIFile
        String sampleName
        String docker_image
    }

    command <<<
        set -uexo pipefail
        
        # Remove read pairs with mapping quality zero
        python /scripts/mapping_quality_filter.py \
        -b ~{BAMFile} \
        -q 50 \
        -d ~{sampleName}.sorted.RG.mz.dumped.bam \
        -mz ~{sampleName}.sorted.RG.mz.filtered.bam

        # Delete unnecessary files
        rm ~{sampleName}.sorted.RG.mz.dumped.bam

    >>>

    runtime {
        docker: docker_image
    }

    output {
        File MZFilteredBAM = "~{sampleName}.sorted.RG.mz.filtered.bam"
    }
}

task PICARD_SortSam {
    input {
        File InputBAM
        String sampleName
        String docker_image
    }

    String outfilename = basename(InputBAM, ".bam")
    
    command <<<
        set -uexo pipefail

        echo " output file basename is : ~{outfilename}"

        #  Sort the BAM file by coordinate
        java -Xmx30g -jar $PICARD SortSam \
        SO=coordinate \
        INPUT=~{InputBAM} \
        OUTPUT=~{outfilename}.sorted.bam \
        CREATE_INDEX=true
    >>>

    runtime {
        docker: docker_image
    }

    output {
        File OutputBAM = "~{outfilename}.sorted.bam"
        File OutputBAMbai = "~{outfilename}.sorted.bai"
    }
}

task abra_realignment {
    input {
        File BWA_reference_tgz
        File InputBAM
        File InputBAMBai
        File genes_200bp
        String sampleName
        String docker_image
    }

    String genome_basename = basename(BWA_reference_tgz, ".tar.gz")

    command <<<
        set -uexo pipefail

        tar xzvf ~{BWA_reference_tgz}

        java -Xmx50G -jar $ABRA \
        --in ~{InputBAM} \
        --out ~{sampleName}.sorted.RG.abraPass1.bam \
        --ref ~{genome_basename}.fa \
        --targets ~{genes_200bp} \
        --threads 6 \
        --working ~{sampleName}.abraPass1_temp_dir \
        --mnf 5 --mbq 150 --mer 0.05

        # Delete the working directory
        rm -rf ~{sampleName}.abraPass1_temp_dir

    >>>

    runtime {
        docker: docker_image
    }

    output {
        File OutputABRABAM = "~{sampleName}.sorted.RG.abraPass1.bam"
    }
}

task PICARDMarkDuplicates {
    input {
        File InputBAM
        File InputBAMBai
        String sampleName
        String docker_image
    }

    String outfilename = basename(InputBAM, ".bam")
    String outfilemetrics = basename(InputBAM, "sorted.bam")

    command {
        set -uexo pipefail
        
        java -Xmx20g -jar $PICARD MarkDuplicates \
        INPUT=~{InputBAM} \
        OUTPUT=~{outfilename}.noDups.bam \
        ASSUME_SORT_ORDER=coordinate \
        METRICS_FILE=~{outfilemetrics}.duplicates.metrics \
        REMOVE_DUPLICATES=true

        samtools index ~{outfilename}.noDups.bam
    }

    runtime {
        docker: docker_image
    }

    output {
        File outbam = "~{outfilename}.noDups.bam"
        File outbambai = "~{outfilename}.noDups.bam.bai"
        File outMetrics = "~{outfilemetrics}.duplicates.metrics"
    }
}

task MakeClinicalBAM {
    input {
        File ABRAbam
        File ABRAbambai
        File clinicalGenes_200bp
        String sampleName
        String docker_image
    }

    command {
        set -uexo pipefail

        samtools view -b -L ~{clinicalGenes_200bp} ~{ABRAbam} > ~{sampleName}.sorted.RG.abraPass1.sorted.noDups.clinical.bam
        
        samtools index ~{sampleName}.sorted.RG.abraPass1.sorted.noDups.clinical.bam
    }

    runtime {
        docker: docker_image
    }

    output {
        File ClinicalBAM = "~{sampleName}.sorted.RG.abraPass1.sorted.noDups.clinical.bam"
        File ClinicalBAMbai = "~{sampleName}.sorted.RG.abraPass1.sorted.noDups.clinical.bam.bai"
    }
}