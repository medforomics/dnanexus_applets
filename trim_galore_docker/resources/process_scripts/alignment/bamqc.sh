#!/bin/bash
#trimgalore.sh

usage() {
  echo "-h Help documentation for hisat.sh"
  echo "-r  --Reference Genome: GRCh38 or GRCm38"
  echo "-b  --BAM File"
  echo "-n  --NucType"
  echo "-p  --Prefix for output file name"
  echo "-c  --Capture Bedfile"
  echo "-d  --RemoveDuplicates 1=yes, 0=no default=no"
  echo "Example: bash bamqc.sh -p prefix -r /project/shared/bicf_workflow_ref/human/GRCh38 -b SRR1551047.bam  -n dna -c target.bed"
  exit 1
}
OPTIND=1 # Reset OPTIND
while getopts :r:b:c:n:p:s:d:h opt
do
    case $opt in
        r) index_path=$OPTARG;;
        b) sbam=$OPTARG;;
        c) bed=$OPTARG;;
        n) nuctype=$OPTARG;;
        p) pair_id=$OPTARG;;
	d) dedup=$OPTARG;;
	s) skiplc=1;;
        h) usage;;
    esac
done

shift $(($OPTIND -1))

# Check for mandatory options
#if [[ -z $pair_id ]] || [[ -z $sbam ]]; then
#    usage
#fi

source /etc/profile.d/modules.sh
module load samtools/1.6 fastqc/0.11.5
samtools flagstat ${sbam} > ${pair_id}.flagstat.txt
fastqc -f bam ${sbam}
baseDir="`dirname \"$0\"`"

if [[ -z $SLURM_CPUS_ON_NODE ]]
then
    SLURM_CPUS_ON_NODE=1
fi

if [[ $dedup == 1 ]]
then
    mv $sbam ori.bam
    samtools view -@ $SLURM_CPUS_ON_NODE -F 1024 -b -o ${sbam} ori.bam
fi

if [[ $nuctype == 'dna' ]]; then
    module load bedtools/2.26.0 picard/2.10.3
    if [[ -z $skiplc ]]
    then
	samtools view -@ $SLURM_CPUS_ON_NODE -b -L ${bed} -o ${pair_id}.ontarget.bam ${sbam}
	samtools index -@ $SLURM_CPUS_ON_NODE ${pair_id}.ontarget.bam
	samtools flagstat  ${pair_id}.ontarget.bam > ${pair_id}.ontarget.flagstat.txt
	java -Xmx64g -jar $PICARD/picard.jar CollectAlignmentSummaryMetrics R=${index_path}/genome.fa I=${pair_id}.ontarget.bam OUTPUT=${pair_id}.alignmentsummarymetrics.txt
	java -Xmx64g -XX:ParallelGCThreads=$SLURM_CPUS_ON_NODE -jar $PICARD/picard.jar EstimateLibraryComplexity I=${sbam} OUTPUT=${pair_id}.libcomplex.txt    
	samtools view  -@ $SLURM_CPUS_ON_NODE -b -q 1 ${sbam} | bedtools coverage -sorted -hist -g ${index_path}/genomefile.txt -b stdin -a ${bed} > ${pair_id}.mapqualcov.txt
	samtools view  -@ $SLURM_CPUS_ON_NODE ${sbam} | awk '{sum+=$5} END { print "Mean MAPQ =",sum/NR}' > ${pair_id}.meanmap.txt
    fi
    java -Xmx64g -jar $PICARD/picard.jar CollectInsertSizeMetrics INPUT=${sbam} HISTOGRAM_FILE=${pair_id}.hist.ps REFERENCE_SEQUENCE=${index_path}/genome.fa OUTPUT=${pair_id}.hist.txt
    bedtools coverage -sorted -g  ${index_path}/genomefile.txt -a ${bed} -b ${sbam} -hist > ${pair_id}.covhist.txt
    grep ^all ${pair_id}.covhist.txt >  ${pair_id}.genomecov.txt
    perl $baseDir/calculate_depthcov.pl ${pair_id}.covhist.txt
fi
