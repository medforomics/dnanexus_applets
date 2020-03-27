version 1.0

## Maintainer: Pankhuri Wanjari
## Contact: pwanjari@bsd.uchicago.edu
## References: gatk workflows

import "Trimmomatic.wdl" as trimmer
import "Alignment.wdl" as align

workflow OncoPlusJob1 {
    
    input {
        String docker_image
        String sample_name
        File FastqR1
        File FastqR2
        File genome_index_tgz
        File ClinicalGenesBED
        File genesBED
    }
    
    call trimmer.trimmomatic as Trimmomatic {
        input: 
        docker_image=docker_image,
        FastqR1=FastqR1,
        FastqR2=FastqR2,
        sampleName=sample_name
    }

    call align.bwa_mem as bwa_mem {
        input:
        docker_image=docker_image,
        BWA_reference_tgz=genome_index_tgz,
        sampleName=sample_name,
        trimmedFastqR1=Trimmomatic.trimmedFastqR1,
        trimmedFastqR2=Trimmomatic.trimmedFastqR2,
    }

    call align.mapq0_filter as MAPQ0Filter {
        input:
        docker_image=docker_image,
        sampleName=sample_name,
        BAMFile=bwa_mem.bam,
        BAIFile=bwa_mem.bam_bai
    }

    call align.PICARD_SortSam as SortSam4mzBAM {
        input:
        docker_image=docker_image,
        sampleName=sample_name,
        InputBAM=MAPQ0Filter.MZFilteredBAM
    }

    call align.abra_realignment as ABRA {
        input:
        BWA_reference_tgz=genome_index_tgz,
        docker_image=docker_image,
        sampleName=sample_name,
        InputBAM=SortSam4mzBAM.OutputBAM,
        InputBAMBai=SortSam4mzBAM.OutputBAMbai,
        genes_200bp=genesBED
    }

    call align.PICARD_SortSam as SortSam4ABRA {
        input:
        docker_image=docker_image,
        sampleName=sample_name,
        InputBAM=ABRA.OutputABRABAM
    }

    call align.PICARDMarkDuplicates as MarkDuplicates {
        input:
        docker_image=docker_image,
        sampleName=sample_name,
        InputBAM=SortSam4ABRA.OutputBAM,
        InputBAMBai=SortSam4ABRA.OutputBAMbai,
    }

    call align.MakeClinicalBAM as clinicalBAM {
        input:
        docker_image=docker_image,
        sampleName=sample_name,
        clinicalGenes_200bp=ClinicalGenesBED,
        ABRAbam=MarkDuplicates.outbam,
        ABRAbambai=MarkDuplicates.outbambai
    }

    output {
        File ClinicalBAM=clinicalBAM.ClinicalBAM
        File ClinicalBAMbai=clinicalBAM.ClinicalBAMbai
    }
}
