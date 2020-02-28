#!/bin/bash
# freebayes 0.0.1
# Generated by dx-app-wizard.

main() {

    dx download "$Consensus_Tumor_BAM" -o tumor.bam
    dx download "$reference" -o dnaref.tar.gz

    tar xvfz dnaref.tar.gz

    if [[ ! -z "$Consensus_Normal_BAM" ]]
    then
        dx download "$Consensus_Normal_BAM" -o normal.bam
    fi

    docker run -v ${PWD}:/data docker.io/goalconsortium/variantcalling:v1 bash /usr/local/bin/indexbams.sh
    docker run -v ${PWD}:/data docker.io/goalconsortium/variantcalling:v1 bash /usr/local/bin/germline_vc.sh -r dnaref -p ${pair_id} -a freebayes
    docker run -v ${PWD}:/data docker.io/goalconsortium/variantcalling:v1 bash /usr/local/bin/uni_norm_annot.sh -g 'GRCh38.92' -r dnaref -p ${pair_id}.fb -v ${pair_id}.freebayes.vcf.gz

    freebayes_vcf=$(dx upload ${pair_id}.fb.vcf.gz --brief)

    dx-jobutil-add-output freebayes_vcf "$freebayes_vcf" --class=file
}
