#!/bin/bash
# cnvkit_createpanelref 0.0.1

main() {

    echo "Value of bams: '${bams[@]}'"
    echo "Value of panelbed: '$panelbed'"
    echo "Value of refFlat: '$reference'"

    dx download "$panelbed" -o panel.bed
    dx download "$reference" -o ref.tar.gz
    mkdir dnaref
    docker run -v ${PWD}:/data docker.io/goalconsortium/structuralvariant:1.0.9 tar -I pigz -xvf ref.tar.gz --no-same-owner --strip-components=1

    for i in ${!bams[@]}
    do
        dx download "${bams[$i]}" -o pon-${i}.bam
    done

    anopt=''
    if [[ -f refFlat.txt ]]
    then
	anopt="--annotate refFlat.txt"
    fi
    docker run -v ${PWD}:/data docker.io/goalconsortium/structuralvariant:1.0.9 cnvkit.py target panel.bed ${anopt} --split -o cnvkit.targets.bed
    docker run -v ${PWD}:/data docker.io/goalconsortium/structuralvariant:1.0.9 cnvkit.py antitarget panel.bed -o cnvkit.antitargets.bed
    
    for i in *.bam
    do
	prefix="${i%.bam}"
	docker run -v ${PWD}:/data docker.io/goalconsortium/structuralvariant:1.0.9 cnvkit.py coverage $i cnvkit.targets.bed -o ${prefix}.targetcoverage.cnn
	docker run -v ${PWD}:/data docker.io/goalconsortium/structuralvariant:1.0.9 cnvkit.py coverage $i cnvkit.antitargets.bed -o ${prefix}.antitargetcoverage.cnn
    done

    docker run -v ${PWD}:/data docker.io/goalconsortium/structuralvariant:1.0.9 cnvkit.py reference *coverage.cnn -f genome.fa -o pon.cnn

    tar cfz cnvkit_pon.tar.gz pon.cnn cnvkit.targets.bed cnvkit.antitargets.bed
    
    poncnn=$(dx upload cnvkit_pon.tar.gz --brief)
    dx-jobutil-add-output poncnn "$poncnn" --class=file
}
