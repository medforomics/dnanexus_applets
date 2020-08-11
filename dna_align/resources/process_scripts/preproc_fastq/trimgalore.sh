#!/bin/bash
#trimgalore.sh

usage() {
  echo "-h Help documentation for hisat.sh"
  echo "-a  --FastQ R1"
  echo "-b  --FastQ R2"
  echo "-p  --Prefix for output file name"
  echo "Example: bash trimgalore.sh -p prefix -a SRR1551047_1.fastq.gz  -b SRR1551047_2.fastq.gz"
  exit 1
}
OPTIND=1 # Reset OPTIND
while getopts :a:b:p:h opt
do
    case $opt in
        a) fq1=$OPTARG;;
        b) fq2=$OPTARG;;
        p) pair_id=$OPTARG;;
        h) usage;;
    esac
done

shift $(($OPTIND -1))

# Check for mandatory options
if [[ -z $pair_id ]] || [[ -z $fq1 ]]; then
    usage
fi

r1base="${fq1%.fastq*}"
r2base="${fq2%.fastq*}"
source /etc/profile.d/modules.sh
module load trimgalore/0.4.1 cutadapt/1.9.1

if [ -s $fq2 ]
then
    trim_galore --paired -q 25 --illumina --gzip --length 35 ${fq1} ${fq2}
    mv ${r1base}_val_1.fq.gz ${pair_id}.trim.R1.fastq.gz
    mv ${r2base}_val_2.fq.gz ${pair_id}.trim.R2.fastq.gz
else
    trim_galore -q 25 --illumina --gzip --length 35 ${fq1}
    mv ${r1base}_trimmed.fq.gz ${pair_id}.trim.R1.fastq.gz
    cp ${pair_id}.trim.R1.fastq.gz ${pair_id}.trim.R2.fastq.gz 
fi
