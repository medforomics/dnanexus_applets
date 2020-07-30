#!/bin/bash
#indexbams.sh

usage() {
  echo "-h  --Help documentation for markdups.sh"
  echo "Example: bash indexbams.sh"
  echo "-r  --Reference Genome: GRCh38 or GRCm38"

  exit 1
}
OPTIND=1 # Reset OPTIND
while getopts :r:b:p:h opt
do
    case $opt in
        h) usage;;
        r) index_path=$OPTARG;;
        p) pair_id=$OPTARG;;
	b) bam=$OPTARG;;
    esac
done

shift $(($OPTIND -1))

# Check for mandatory options

if [[ -z $SLURM_CPUS_ON_NODE ]]
then
    SLURM_CPUS_ON_NODE=1
fi
baseDir="`dirname \"$0\"`"

source /etc/profile.d/modules.sh
module load igvtools/2.3.71 samtools/1.6
samtools index  -@ $SLURM_CPUS_ON_NODE $bam
igvtools count -z 5 $bam ${pair_id}.tdf ${index_path}/igv/human.genome
