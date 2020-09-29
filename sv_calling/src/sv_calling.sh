#!/bin/bash
# Structural_Variants
# Generated by dx-app-wizard.

main() {

    dx download "$tbam" -o ${caseid}.tumor.bam
    dx download "$reference" -o ref.tar.gz

    mkdir dnaref
    docker run -v ${PWD}:/data docker.io/goalconsortium/structuralvariant:1.0.4 tar -I pigz -xvf ref.tar.gz --strip-components=1 -C dnaref

    if [ -n "$panel" ]
    then
        dx download "$panel" -o panel.tar.gz
	mkdir -p panel
	docker run -v ${PWD}:/data docker.io/goalconsortium/structuralvariant:1.0.4 tar -I pigz -xvf panel.tar.gz -C panel/
    fi

    if [ -n "$nbam" ]
    then
        dx download "$nbam" -o ${caseid}.normal.bam
    fi
    
    docker run -v ${PWD}:/data docker.io/goalconsortium/structuralvariant:1.0.4 bash /seqprg/process_scripts/alignment/indexbams.sh
    
    normopt=''
    if [[ -n "$nbam" ]]
    then
	normopt=" -n ${caseid}.normal.bam"
    fi
    
    outfile=''

    echo "$algo"
    
    for a in $algo
    do
	echo "Starting ${a}"
	outfile+=".${a}"
	
	if [[ "${a}" =~ "pindel" ]]
	then
	    targetbed='dnaref/targetpanel.bed'
	    if [[ "${a}" == "pindel_itd" ]]
	    then
		targetbed='dnaref/pindel_genes.bed'
	    fi
	    docker run -v ${PWD}:/data docker.io/goalconsortium/structuralvariant:1.0.4 bash /seqprg/process_scripts/variants/svcalling.sh -r dnaref -p $caseid -l dnaref/itd_genes.bed -c $targetbed -a pindel -g GRCh38.86 -f
	    tar -czvf ${caseid}${outfile}.vcf.tar.gz *.pindel.vcf.gz
	    vcf=$(dx upload ${caseid}${outfile}.vcf.tar.gz --brief)
	    dx-jobutil-add-output vcf "$vcf" --class=file  
	elif [[ "${a}" == "delly" ]] || [[ "${a}" == "svaba" ]]
	then
            docker run -v ${PWD}:/data docker.io/goalconsortium/structuralvariant:1.0.4 bash /seqprg/process_scripts/variants/svcalling.sh -r dnaref -b ${caseid}.tumor.bam -p ${caseid} -a ${a} -g GRCh38.86 $normopt -f
	elif [[ "${a}" == "itdseek" ]]
	then
	    docker run -v ${PWD}:/data docker.io/goalconsortium/structuralvariant:1.0.4 bash /seqprg/process_scripts/variants/svcalling.sh -r dnaref -b ${caseid}.tumor.bam -p ${caseid} -a ${a} -l dnaref/itd_genes.bed -g GRCh38.86 -f
	elif [[ "${a}" == "cnvkit" ]]
	then
	    docker run -v ${PWD}:/data docker.io/goalconsortium/structuralvariant:1.0.4 bash /seqprg/process_scripts/variants/cnvkit.sh -r dnaref -b ${caseid}.tumor.bam -p ${caseid} -d panel
	    tar -czvf ${caseid}.cnvout.tar.gz ${caseid}.answerplot* *cnv.answer.txt *ballelefreq.txt ${caseid}.call.cns ${caseid}.cns ${caseid}.cnr
	    cnvout=$(dx upload ${caseid}.cnvout.tar.gz --brief)
	    dx-jobutil-add-output cnvout "$cnvout" --class=file
	else
            echo "Incorrect algorithm selection. Please select 1 of the following algorithms: pindel delly svaba cnvkit itdseek"
	fi
    done
    
    if [[ "${algo}" =~ "delly" ]] || [[ "${algo}" =~ "svaba" ]] || [[ "${algo}" =~ "itdseek" ]] || [[ "${algo}" =~ "pindel" ]]
    then
	tar -czvf ${caseid}${outfile}.sv.tar.gz *.vcf.gz
	svvcf=$(dx upload ${caseid}${outfile}.sv.tar.gz --brief)
	dx-jobutil-add-output svvcf "$svvcf" --class=file
    fi
    if [[ "${algo}" =~ "delly" ]] || [[ "${algo}" =~ "svaba" ]]
    then
	tar -czvf ${caseid}${outfile}.gf.tar.gz ${caseid}*.txt
	genefusion=$(dx upload ${caseid}${outfile}.gf.tar.gz --brief)
	dx-jobutil-add-output genefusion "$genefusion" --class=file
    fi
}
