#!/bin/bash
#Usage:<script_name.sh>local_fastq_filename.fastq 4

usage() {
  echo "-h Help documentation for gatkrunner.sh"
  echo "-i  --input fastq directory"
  echo "-d  --design designfile.txt"
  echo "-w  --workflow DNA Nexus Workflow"
  echo "Example: bash run_workflow.sh -i fastq_dir -d design.txt -w worflow_name"
  exit 1
}
OPTIND=1 # Reset OPTIND
while getopts :i:w:d:h opt
do
    case $opt in
        i) inputdir=$OPTARG;;
        d) design=$OPTARG;;
        w) wkflow=$OPTARG;;
	h) usage;;
    esac
done

shift $(($OPTIND -1))
fqdir=$inputdir
while read i; do
    line=($i)
    colnames=($(head -n 1 $design))
    opts=''
    declare -A fqfiles
    while [ "${#colnames[@]}" -gt 0 ] ; do
	eval ${colnames[0]}="${line[0]}"
	if [[ ! ${colnames[0]} =~ 'FqR' ]] && [[ ${colnames[0]} != 'RunID' ]] && [[ ${colnames[0]} != 'PanelFile' ]]
	then
	    opts="$opts -i${colnames[0]}=${line[0]}"
	elif [[ ${colnames[0]} =~ 'FqR' ]]
	then
	    fqfiles[${colnames[0]}]=${line[0]}
	fi
	colnames=( "${colnames[@]:1}" )
	line=( "${line[@]:1}" )
    done
    if [[ $CaseID != "CaseID" ]]
    then
	if [[ -n $PanelFile ]]
	then
	    PanelFile="/referencedata/${PanelFile}.tar.gz"
	fi
	fqopt=''
	dx mkdir -p /$RunID/$CaseID
	for fq in "${!fqfiles[@]}"
	do
	    read="${fqdir}/${fqfiles[$fq]}"
	    Fq=$(dx upload "$read" --destination /$RunID/$CaseID/ --brief)
	    #Fq=$read
	    fqopt="$fqopt -i${fq}=$Fq"
	done
	runwkflow=$(dx run $wkflow $opts $fqopt -iPanelFile=$PanelFile --destination /$RunID/$CaseID)
	#echo "dx run $wkflow $opts $fqopt -iPanelFile=$PanelFile --destination /$RunID/$CaseID"
	echo $opts $runwkflow >> ${wkflow}.joblist.txt
    fi 
done <$design