#!/bin/bash
#monitor_jobs.sh

set -e

jobbase='/project/PHG/PHG_Clinical/cloud'
processing='/project/PHG/PHG_Clinical/processing'

for i in ${jobbase}/pending/*.joblist.txt
do
    filename="$(basename -- $i)"
    runid=$(echo $filename | cut -f 1 -d  '.')
    caseid=$(echo $filename | cut -f 2 -d  '.')
    complete=0
    fail=0
    numjobs=$(wc -l $i |cut -f 1 -d ' ')
    cd ${processing}/${runid}/${caseid}
    while reads j
    do
	dx describe $j --json > $j.json
	state=$(cat $j.json | jq -r '.state')
	if [[ $state == 'done' ]]
	then
	    complete=$((complete+1))
	elif [[ $state == 'fail' ]]
	then
	    fail=1
	    SUBJECT="SECUREMAIL: Case Job Failed: $j"
            TO="ngsclialab@UTSouthwestern.edu,Chelsea.Raulerson@UTSouthwestern.edu"
            email=$baseDir"/scripts/dnanexus_email.txt"
	    cat $email | sed 's/Unspecified/'$j'/' | /bin/mail -s "$SUBJECT" "$TO"
	fi
    done<$i
    if [[ $complete == $numjobs ]]
    then
	mv $i $jobbase/complete
	mkdir -p ${processing}/${runid}/${caseid}/analysis
	cd ${processing}/${runid}/${caseid}/analysis
	dx find data --path /${runid}/${caseid} --json > files.json
	filemap=$(cat files.json | jq -c '.[] | [.describe.name, .describe.id]')
	for i in $filemap
	do
	    line=$(echo $i | column -t -s'[],"')
	    myarray=($line)
	    if [[ ! ${myarray[0]} =~ 'fastq.gz' ]] && [[ ! ${myarray[0]} =~ 'final.ba' ]]
	    then
		echo "dx download ${myarray[1]}"
	    else
		echo "skipping ${myarray[0]}"
	    fi
	done
    elif [[ $fail == 1 ]]
	 mv $i $jobbase/archive
    fi
done
