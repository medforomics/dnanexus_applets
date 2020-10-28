#!/bin/bash
#hisat.sh

usage() {
  echo "-h  --Help documentation for markdups.sh"
  echo "-m  --Mark Duplication Method: sambamba, samtools, picard, picard_umi, fgbio_umi, null; default is null"
  echo "-b  --BAM file"
  echo "-p  --Prefix for output file name"
  echo "Example: bash markdups.sh -p prefix -b file.bam -a picard"
  exit 1
}
OPTIND=1 # Reset OPTIND
while getopts :a:b:p:h opt
do
    case $opt in
        a) algo=$OPTARG;;
        b) sbam=$OPTARG;;
        p) pair_id=$OPTARG;;
        h) usage;;
    esac
done

shift $(($OPTIND -1))

# Check for mandatory options
if [[ -z $pair_id ]] || [[ -z $sbam ]]; then
    usage
fi

if [[ -z $SLURM_CPUS_ON_NODE ]]
then
    SLURM_CPUS_ON_NODE=1
fi
baseDir="`dirname \"$0\"`"

source /etc/profile.d/modules.sh
module load picard/2.10.3 samtools/gcc/1.8

if [ $algo == 'sambamba' ]
then
    module load speedseq/20160506
    sambamba markdup -t $SLURM_CPUS_ON_NODE ${sbam} ${pair_id}.dedup.bam
elif [ $algo == 'samtools' ]
then
    samtools markdup -s --output-fmt BAM -@ $SLURM_CPUS_ON_NODE sort.bam ${pair_id}.dedup.bam
elif [ $algo == 'picard' ]
then
    java -XX:ParallelGCThreads=$SLURM_CPUS_ON_NODE -Djava.io.tmpdir=./ -Xmx16g  -jar $PICARD/picard.jar MarkDuplicates I=${sbam} O=${pair_id}.dedup.bam M=${pair_id}.dedup.stat.txt
elif [ $algo == 'picard_umi' ]
then
    java -XX:ParallelGCThreads=$SLURM_CPUS_ON_NODE -Djava.io.tmpdir=./ -Xmx16g  -jar $PICARD/picard.jar MarkDuplicates BARCODE_TAG=RX I=${sbam} O=${pair_id}.dedup.bam M=${pair_id}.dedup.stat.txt
elif [ $algo == 'fgbio_umi' ]   
then
    module load fgbio bwa/intel/0.7.15
    samtools index -@ $SLURM_CPUS_ON_NODE ${sbam}
    fgbio GroupReadsByUmi -s identity -i ${sbam} -o ${pair_id}.group.bam --family-size-histogram ${pair_id}.umihist.txt -e 0 -m 0
    fgbio CallMolecularConsensusReads -i ${pair_id}.group.bam -p consensus -M 1 -o ${pair_id}.consensus.bam -S ':none:'
    samtools index ${pair_id}.consensus.bam
    samtools fastq -1 ${pair_id}.consensus.R1.fastq -2 ${pair_id}.consensus.R2.fastq ${pair_id}.consensus.bam
    gzip ${pair_id}.consensus.R1.fastq
    gzip ${pair_id}.consensus.R2.fastq
    bwa mem -M -C -t $SLURM_CPUS_ON_NODE -R "@RG\tID:${pair_id}\tLB:tx\tPL:illumina\tPU:barcode\tSM:${pair_id}" /project/shared/bicf_workflow_ref/human/GRCh38/genome.fa ${pair_id}.consensus.R1.fastq.gz ${pair_id}.consensus.R2.fastq.gz | samtools view -1 - > ${pair_id}.consensus.bam
    samtools sort --threads $SLURM_CPUS_ON_NODE -o ${pair_id}.dedup.bam ${pair_id}.consensus.bam
else
    cp ${sbam} ${pair_id}.dedup.bam    
fi
samtools index -@ $SLURM_CPUS_ON_NODE ${pair_id}.dedup.bam
