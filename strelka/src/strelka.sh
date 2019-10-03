#!/bin/bash
# strelka 0.0.1
# Generated by dx-app-wizard.
#
# Basic execution pattern: Your app will run on a single machine from
# beginning to end.
#
# Your job's input variables (if any) will be loaded as environment
# variables before this script runs.  Any array inputs will be loaded
# as bash arrays.
#
# Any code outside of main() (or any entry point you may add) is
# ALWAYS executed, followed by running the entry point itself.
#
# See https://wiki.dnanexus.com/Developer-Portal for tutorials on how
# to modify this file.

main() {

    echo "Value of Consensus_BAM: '$Consensus_BAM'"
    echo "Value of ref_file: '$ref_file'"
    echo "Value of pair_id: '$pair_id'"

    # The following line(s) use the dx command-line tool to download your file
    # inputs to the local file system using variable names for the filenames. To
    # recover the original filenames, you can use the output of "dx describe
    # "$variable" --name".

    dx download "$Consensus_BAM" -o consensus.bam
    dx download "$ref_file" -o reference.tar.gz

    if [[ -z $pair_id ]]
    then
        pair_id='seq'
    fi
    echo "Value of pair_id: '$pair_id'"

    tar xvfz reference.tar.gz
    gunzip reference/genome.fa.gz

    mkdir manta strelka

    docker run -v ${PWD}:/data docker.io/goalconsortium/variantcalling:v1 configManta.py consensus.bam --referenceFasta reference/genome.fa $mode --runDir manta
    docker run -v ${PWD}:/data docker.io/goalconsortium/variantcalling:v1 manta/runWorkflow.py -m local -j 1
    docker run -v ${PWD}:/data docker.io/goalconsortium/variantcalling:v1 configureStrelkaGermlineWorkflow.py consensus.bam --referenceFasta reference/genome.fa $mode --indelCandidates manta/results/variants/candidateSmallIndels.vcf.gz --runDir strelka
    docker run -v ${PWD}:/data docker.io/goalconsortium/variantcalling:v1 strelka/runWorkflow.py -m local -j 1
    docker run -v ${PWD}:/data docker.io/goalconsortium/variantcalling:v1 bcftools norm -c s -f reference/genome.fa -w 10 -O z -o ${pair_id}.strelka2.vcf.gz strelka/results/variants/variants.vcf.gz

    strelka2_vcf=$(dx upload ${pair_id}.strelka2.vcf.gz --brief)

    # The following line(s) use the utility dx-jobutil-add-output to format and
    # add output variables to your job's output as appropriate for the output
    # class.  Run "dx-jobutil-add-output -h" for more information on what it
    # does.

    dx-jobutil-add-output strelka2_vcf "$strelka2_vcf" --class=file
}
