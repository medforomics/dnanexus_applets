#!/bin/bash
# Structural_Variants 0.5.33
# Generated by dx-app-wizard.

main() {

    dx download "$Tumor_BAM" -o ${pair_id}.tumor.bam
    dx download "$reference" -o ref.tar.gz

    mkdir dnaref
    docker run -v ${PWD}:/data docker.io/goalconsortium/structuralvariant:0.5.33 tar -I pigz -xvf ref.tar.gz --strip-components=1 -C dnaref

    if [ -n "$panel" ]
    then
        dx download "$panel" -o panel.tar.gz
	mkdir -p panel
	docker run -v ${PWD}:/data docker.io/goalconsortium/structuralvariant:0.5.33 tar -I pigz -xvf panel.tar.gz -C panel/
    fi

    if [ -n "$Normal_BAM" ]
    then
        dx download "$Normal_BAM" -o ${pair_id}.normal.bam
    fi
    
    docker run -v ${PWD}:/data docker.io/goalconsortium/structuralvariant:0.5.33 bash /seqprg/school/process_scripts/alignment/indexbams.sh
    
    normopt=''
    if [[ -n "$Normal_BAM" ]]
    then
	normopt=" -n ${pair_id}.normal.bam"
    fi

    outfile=''

    echo "$algo"
    
    for a in $algo
    do
	echo "Starting ${a}"
	outfile+=".${a}"
	
	if [[ "${a}" == "pindel" ]]
	then
	    docker run -v ${PWD}:/data docker.io/goalconsortium/structuralvariant:0.5.33 bash /seqprg/school/process_scripts/variants/svcalling.sh -r dnaref -p $pair_id -l dnaref/itd_genes.bed -c dnaref/itd_genes.bed -a ${a} -g GRCh38.92 -f
	elif [[ "${a}" == "delly" ]] || [[ "${a}" == "svaba" ]]
	then
            docker run -v ${PWD}:/data docker.io/goalconsortium/structuralvariant:0.5.33 bash /seqprg/school/process_scripts/variants/svcalling.sh -r dnaref -b ${pair_id}.tumor.bam -p ${pair_id} -a ${a} -g GRCh38.92 $normopt -f
	elif [[ "${a}" == "itdseek" ]]
	then
	    docker run -v ${PWD}:/data docker.io/goalconsortium/structuralvariant:0.5.33 bash /seqprg/school/process_scripts/variants/svcalling.sh -r dnaref -b ${pair_id}.tumor.bam -p ${pair_id} -a ${a} -l dnaref/itd_genes.bed -g GRCh38.92 -f
	elif [[ "${a}" == "cnvkit" ]]
	then
	    docker run -v ${PWD}:/data docker.io/goalconsortium/structuralvariant:0.5.33 bash /seqprg/school/process_scripts/variants/cnvkit.sh -r dnaref -b ${pair_id}.tumor.bam -p ${pair_id} -d panel
	    tar -czvf ${pair_id}.cnvout.tar.gz ${pair_id}.answerplot* *cnv.answer.txt *ballelefreq.txt ${pair_id}.call.cns ${pair_id}.cns ${pair_id}.cnr
	    cnvout=$(dx upload ${pair_id}.cnvout.tar.gz --brief)
	    dx-jobutil-add-output cnvout "$cnvout" --class=file
	else
            echo "Incorrect algorithm selection. Please select 1 of the following algorithms: pindel delly svaba cnvkit itdseek"
	fi
    done
    
    if [[ "${a}" == "delly" ]] || [[ "${a}" == "svaba" ]] || [[ "${a}" == "itdseek" ]] || [[ "${a}" == "pindel" ]]
    then
	tar -czvf ${pair_id}${outfile}.sv.tar.gz *.vcf.gz
	svvcf=$(dx upload ${pair_id}${outfile}.sv.tar.gz --brief)
	dx-jobutil-add-output svvcf "$svvcf" --class=file
    fi
    if [[ "${a}" == "delly" ]] || [[ "${a}" == "svaba" ]] || [[ "${a}" == "pindel" ]]
    then
	tar -czvf ${pair_id}${outfile}.gf.tar.gz ${pair_id}*.txt
	genefusion=$(dx upload ${pair_id}${outfile}.gf.tar.gz --brief)
	dx-jobutil-add-output genefusion "$genefusion" --class=file
    fi
}
