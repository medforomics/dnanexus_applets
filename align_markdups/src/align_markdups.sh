#!/bin/bash
# align_markdups 0.0.1
# Generated by dx-app-wizard.

main() {

    dx download "$fq1" -o seq.R1.fastq.gz
    dx download "$fq2" -o seq.R2.fastq.gz
    dx download "$reference" -o dnaref.tar.gz

    tar xvfz dnaref.tar.gz

    if [[ ${mdup} == 'fgbio_umi' ]]
    then
    docker run -v ${PWD}:/data docker.io/goalconsortium/alignment:1.0.0 bash /usr/local/bin/dnaseqalign.sh -r dnaref -a ${aligner} -p ${pair_id} -x seq.R1.fastq.gz -y seq.R2.fastq.gz -u
    else
    docker run -v ${PWD}:/data docker.io/goalconsortium/alignment:1.0.0 bash /usr/local/bin/dnaseqalign.sh -r dnaref -a ${aligner} -p ${pair_id} -x seq.R1.fastq.gz -y seq.R2.fastq.gz
    fi
    docker run -v ${PWD}:/data docker.io/goalconsortium/alignment:1.0.0 bash /usr/local/bin/markdups.sh -a ${mdup} -b ${pair_id}.bam -p ${pair_id} -r dnaref
    mv ${pair_id}.dedup.bam ${pair_id}.consensus.bam
    mv ${pair_id}.dedup.bam.bai ${pair_id}.consensus.bam.bai

    rawbam=$(dx upload ${pair_id}.bam --brief)
    conbam=$(dx upload ${pair_id}.consensus.bam --brief)
    grbam=$(dx upload ${pair_id}.group.bam --brief)
    rawbai=$(dx upload ${pair_id}.bam.bai --brief)
    conbai=$(dx upload ${pair_id}.consensus.bam.bai --brief)
    grbai=$(dx upload ${pair_id}.group.bam.bai --brief)

    dx-jobutil-add-output rawbam "$rawbam" --class=file
    dx-jobutil-add-output conbam "$conbam" --class=file
    dx-jobutil-add-output grbam "$grbam" --class=file
    dx-jobutil-add-output rawbai "$rawbai" --class=file
    dx-jobutil-add-output conbai "$conbai" --class=file
    dx-jobutil-add-output grbai "$grbai" --class=file
}
