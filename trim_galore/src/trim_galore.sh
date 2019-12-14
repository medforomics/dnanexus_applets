#!/bin/bash
# trim_galore 0.0.1
# Generated by dx-app-wizard.
#
# Basic execution pattern: Your app will run on a single machine from
# beginning to end.
#
# Your job's input variables (if any) will be loaded as environment
# variables before this script runs.  Any array inputs will be loaded
# as bash arrays.
#
# Any code outside of main() (or any entry point you may add) is
# ALWAYS executed, followed by running the entry point itself.
#
# See https://wiki.dnanexus.com/Developer-Portal for tutorials on how
# to modify this file.

main() {
    # The following line(s) use the dx command-line tool to download your file
    # inputs to the local file system using variable names for the filenames. To
    # recover the original filenames, you can use the output of "dx describe
    # "$variable" --name".

    dx download "$fq1" -o seq.R1.fastq.gz
    if [ -n "$fq2" ]
    then
        dx download "$fq2" -o seq.R2.fastq.gz
    fi

    docker run -v ${PWD}:/data docker.io/goalconsortium/trim_galore:v1 bash /usr/local/bin/trimgalore.sh -p ${pair_id} -a seq.R1.fastq.gz -b seq.R2.fastq.gz
    docker run -v ${PWD}:/data docker.io/goalconsortium/trim_galore:v1 perl /usr/local/bin/parse_trimreport.pl ${pair_id}.trimreport.txt *trimming_report.txt

    trim1=$(dx upload ${pair_id}.trim.R1.fastq.gz --brief)
    trimreport=$(dx upload ${pair_id}.trimreport.txt --brief)
    
    # The following line(s) use the utility dx-jobutil-add-output to format and
    # add output variables to your job's output as appropriate for the output
    # class.  Run "dx-jobutil-add-output -h" for more information on what it
    # does.

    dx-jobutil-add-output trim1 "$trim1" --class=file
    dx-jobutil-add-output trimreport "$trimreport" --class=file

    if [ -n "$fq2" ]
    then
	trim2=$(dx upload ${pair_id}.trim.R2.fastq.gz --brief)
	dx-jobutil-add-output trim2 "$trim2" --class=file
    fi
}
