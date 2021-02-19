#!/bin/bash
# cnvkit_createpanelref 0.0.1

main() {

    echo "Value of bams: '${bams[@]}'"

    dx download "$reference" -o ref.tar.gz
    docker run -v ${PWD}:/data docker.io/goalconsortium/profiling_qc:1.0.9 tar -I pigz -xvf ref.tar.gz --no-same-owner --strip-components=1

    for i in ${!bams[@]}
    do
        dx download "${bams[$i]}" -o pon-${i}.bam
    done

    docker run -v ${PWD}:/data docker.io/goalconsortium/profiling_qc:1.0.9 msisensor-pro scan -d genome.fa -o microsatellites.list
    
    for i in *.bam
    do
	prefix="${i%.bam}"
	echo $prefix $i >> bam.list
	docker run -v ${PWD}:/data docker.io/goalconsortium/profiling_qc:1.0.9 samtools index $i
    done

    docker run -v ${PWD}:/data docker.io/goalconsortium/profiling_qc:1.0.9  msisensor-pro baseline -d microsatellites.list -i bam.list -o ./

    tar cfz msiref.tar.gz microsatellites.list*
    msibase=$(dx upload msiref.tar.gz --brief)
    dx-jobutil-add-output msibase "$msibase" --class=file
}
