;; This buffer is for text that is not saved, and for Lisp evaluation.
;; To create a file, visit it with C-x C-f and enter text in its buffer.

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
	    opts="$opts -iPanelFile=$PanelFile"
	fi
	if [[ -z $RunID ]]
	then
	    RunID=$seqrunid
	fi
	dx mkdir -p /$RunID/$CaseID
	for fq in "${!fqfiles[@]}"
	do
	    read="${inputdir}/${fqfiles[$fq]}"
	    Fq=$(dx upload $read --destination /$RunID/$CaseID/ --brief)
	    opts="$opts -i${fq}=$Fq"
	done
	runwkflow=$(dx run $wkflow $opts --destination /$RunID/$CaseID -y --brief)
	echo $runwkflow >> ${outdir}/${RunID}.${CaseID}.joblist.txt
    fi 
done <$design
