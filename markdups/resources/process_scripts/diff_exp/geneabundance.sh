#!/bin/bash
#rnaseqalign.sh

usage() {
  echo "-h Help documentation for hisat.sh"
  echo "-b  --BAM File"
  echo "-g  --GTF File"
  echo "-s  --stranded"
  echo "-p  --Prefix for output file name"
  echo "Example: bash geneabudance.sh genect_rnaseq/geneabundance.sh -s stranded -g gtf_file -p pair_id -b bam"
  exit 1
}
OPTIND=1 # Reset OPTIND
while getopts :b:g:p:s:h opt
do
    case $opt in
        b) sbam=$OPTARG;;
        g) gtf=$OPTARG;;
        p) pair_id=$OPTARG;;
        s) stranded=$OPTARG;;
        h) usage;;
    esac
done

shift $(($OPTIND -1))

# Check for mandatory options
if [[ -z $pair_id ]] || [[ -z $sbam ]]
then
    usage
fi
if [[ -z $SLURM_CPUS_ON_NODE ]]
then
    SLURM_CPUS_ON_NODE=1
fi
if [[ $SLURM_CPUS_ON_NODE > 64 ]]
then
    SLURM_CPUS_ON_NODE=64
fi
source /etc/profile.d/modules.sh
module load subread/1.6.1 stringtie/1.3.2d-intel
featureCounts -s $stranded -M --fraction -J --ignoreDup -T $SLURM_CPUS_ON_NODE -p -g gene_name -a ${gtf} -o ${pair_id}.cts ${sbam}
mkdir ${pair_id}_stringtie
cd ${pair_id}_stringtie
stringtie ../${sbam} -p $SLURM_CPUS_ON_NODE -G ${gtf} -B -e -o denovo.gtf -A ../${pair_id}.fpkm.txt
 
