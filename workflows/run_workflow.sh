#!/bin/bash
#Usage:<script_name.sh>local_fastq_filename.fastq 4

usage() {
  echo "-h Help documentation for gatkrunner.sh"
  echo "-w  --projectID"
  echo "-r  --Reference Genome: GRCh38 or GRCm38"
  echo "-b  --baseDir script executable directory"
  echo "-c  --processing dir"
  echo "-x  --checkXML"
  echo "Example: bash init_workflows.sh -p prefix -r /path/GRCh38 -b baseDir -c processingDir"
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
    while [ "${#colnames[@]}" -gt 0 ] ; do
	eval ${colnames[0]}="${line[0]}"
	if [[ ${colnames[0]} != 'FqR1' ]] && [[ ${colnames[0]} != 'FqR2' ]] && [[ ${colnames[0]} != 'RunID' ]] && [[ ${colnames[0]} != 'PanelFile' ]]
	then
	    opts="$opts -i${colnames[0]}=${line[0]}"
	fi
	colnames=( "${colnames[@]:1}" )
	line=( "${line[@]:1}" )
    done
    if [[ $CaseID != "CaseID" ]]
    then
	read1="${fqdir}/$FqR1"
	read2="${fqdir}/$FqR2"
	if [[ -n $PanelFile ]]
	then
	    PanelFile="/referencedata/${PanelFile}.tar.gz"
	fi
	dx mkdir -p /$RunID/$CaseID
	FqR1=$(dx upload "$read1" --destination /$RunID/$CaseID/ --brief)
	FqR2=$(dx upload "$read2" --destination /$RunID/$CaseID/ --brief)
	runwkflow=$(dx run $wkflow $opts -iFqR1=$FqR1 -iFqR2=$FqR2 -iPanelFile=$PanelFile --destination /$RunID/$CaseID)
	#echo "dx run $wkflow $opts -iFqR1=$FqR1 -iFqR2=$FqR2 -iPanelFile=$PanelFile --destination /$RunID/$CaseID";
	echo $opts $runwkflow >> ${wkflow}.joblist.txt
    fi 
done <$design
