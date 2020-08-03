#!/bin/bash
# trim_galore 0.5.36
# Generated by dx-app-wizard.

main() {

    dx download "$fq1" -o seq.R1.fastq.gz
    dx download "$fq2" -o seq.R2.fastq.gz

    docker run -v ${PWD}:/data docker.io/goalconsortium/trim_galore:0.5.36 -f -p ${pair_id} seq.R1.fastq.gz seq.R2.fastq.gz 

    trim1=$(dx upload ${pair_id}.trim.R1.fastq.gz --brief)
    trim2=$(dx upload ${pair_id}.trim.R2.fastq.gz --brief)
    trimreport=$(dx upload ${pair_id}.trimreport.txt --brief)
    
    dx-jobutil-add-output trim1 "$trim1" --class=file
    dx-jobutil-add-output trim2 "$trim2" --class=file
    dx-jobutil-add-output trimreport "$trimreport" --class=file
}
