#!/bin/bash
# shimmer 0.0.1
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

    # The following line(s) use the dx command-line tool to download your file
    # inputs to the local file system using variable names for the filenames. To
    # recover the original filenames, you can use the output of "dx describe
    # "$variable" --name".

    dx download "$tumorbam" -o tumor.bam
    dx download "$normalbam" -o normal.bam
    dx download "$reference" -o reference.tar.gz

    tar xvfz reference.tar.gz
    gunzip reference/genome.fa.gz

    docker run -v ${PWD}:/data docker.io/goalconsortium/variantcalling:v1 shimmer.pl --minqual 25 --ref reference/genome.fa normal.bam tumor.bam --outdir shimmer 2> shimmer.err
    docker run -v ${PWD}:/data docker.io/goalconsortium/variantcalling:v1 perl /usr/local/bin/add_readct_shimmer.pl
    docker run -v ${PWD}:/data docker.io/goalconsortium/variantcalling:v1 sh -c "vcf-annotate -n --fill-type shimmer/somatic_diffs.readct.vcf | java -jar /usr/local/bin/snpEff/SnpSift.jar filter '(GEN[*].DP >= 10)' | perl -pe \"s/TUMOR/${pair_id}/\" | perl -pe \"s/NORMAL/${pair_id}/g\" | bgzip > ${pair_id}.shimmer.vcf.gz"

    shimmer_vcf=$(dx upload ${pair_id}.shimmer.vcf.gz --brief)
    
    # The following line(s) use the utility dx-jobutil-add-output to format and
    # add output variables to your job's output as appropriate for the output
    # class.  Run "dx-jobutil-add-output -h" for more information on what it
    # does.
    
    dx-jobutil-add-output shimmer_vcf "$shimmer_vcf" --class=file
}
