#!/bin/bash
#monitor_jobs.sh

jobbase='/project/PHG/PHG_Clinical/cloud'
for i in ${jobbase}/pending/*.joblist.txt
do
    filename="$(basename -- $i)"
    runid=$(echo $filename | cut -f 1 -d  '.')
    caseid=$(echo $filename | cut -f 2 -d  '.')
    complete=0
    numjobs=$(wc -l demultiplex_dnanexus.sh |cut -f 1 -d ' ')
    while reads j
    do
	dx describe $j --json > $j.json
	#state=done
	if [[ $state == 'done' ]]
	then
	    complete=$((complete+1))
	elif [[ $state == 'failed' ]]
	then
	    ##email ngsclialab@utsouthwestern.edu
	fi
    done<$i
    if [[ $complete == $numjobs ]]
    then
	dx find data --path /${runid}/${caseid} --json > files.json
	#exclude fastq and final.bam files
    fi
done
