#!/bin/bash
#dnaseqalign.sh

usage() {
  echo "-h Help documentation for dnaseqalign.sh"
  echo "-r  --Reference Genome: GRCh38 or GRCm38"
  echo "-x  --FastQ R1"
  echo "-y  --FastQ R2"
  echo "-p  --Prefix for output file name"
  echo "-u  --UMI"
  echo "Example: bash dnaseqalign.sh -p prefix -u 1 -r /project/shared/bicf_workflow_ref/human/GRCh38 -x SRR1551047_1.fastq.gz  -y SRR1551047_2.fastq.gz"
  exit 1
}
OPTIND=1 # Reset OPTIND
while getopts :r:x:y:g:p:a:uh opt
do
    case $opt in
        r) index_path=$OPTARG;;
        x) fq1=$OPTARG;;
        y) fq2=$OPTARG;;
	u) umi='umi';;
	g) read_group=$OPTARG;;
        p) pair_id=$OPTARG;;
	a) aligner=$OPTARG;;
        h) usage;;
    esac
done

shift $(($OPTIND -1))

# Check for mandatory options
if [[ -z $pair_id ]] || [[ -z $fq1 ]]; then
    usage
fi

if [[ -z $SLURM_CPUS_ON_NODE ]]
then
    SLURM_CPUS_ON_NODE=1
fi

if [[ -z $read_group ]]
then
    read_group=$pair_id
fi

testexe='/project/shared/bicf_workflow_ref/seqprg/bin'

source /etc/profile.d/modules.sh
module load  python/2.7.x-anaconda bwakit/0.7.15 samtools/gcc/1.8 picard/2.10.3

baseDir="`dirname \"$0\"`"

diff $fq1 $fq2 > difffile
if [[ $aligner == 'bwa' ]]
then
    module load bwa/intel/0.7.17
    if [ -s difffile ]
	then
    	bwa mem -M -t $SLURM_CPUS_ON_NODE -R "@RG\tID:${read_group}\tLB:tx\tPL:illumina\tPU:barcode\tSM:${read_group}" ${index_path}/genome.fa ${fq1} ${fq2} > out.sam
	else
    	bwa mem -M -t $SLURM_CPUS_ON_NODE -R "@RG\tID:${read_group}\tLB:tx\tPL:illumina\tPU:barcode\tSM:${read_group}" ${index_path}/genome.fa ${fq1} > out.sam
	fi
elif [[ $aligner == 'hisat2' ]]
then
	module load hisat2/2.1.0-intel
	hisat2 -p $SLURM_CPUS_ON_NODE --rg-id ${pair_id} --rg LB:tx --rg PL:illumina --rg PU:barcode --rg SM:${pair_id} --no-unal -x ${index_path}/hisat_index/genome -1 $fq1 -2 $fq2 -S out.sam --summary-file ${pair_id}.alignerout.txt		
fi

if [[ $umi == 'umi' ]] && [[ $index_path == '/project/shared/bicf_workflow_ref/human/GRCh38' ]]
then
    k8 ${testexe}/bwa-postalt.js -p tmphla ${index_path}/genome.fa.alt out.sam | python ${baseDir}/add_umi_sam.py -s - -o output.unsort.bam
elif [[ $index_path == '/project/shared/bicf_workflow_ref/human/GRCh38' ]]
then
    k8 ${testexe}/bwa-postalt.js -p tmphla ${index_path}/genome.fa.alt out.sam| samtools view -1 - > output.unsort.bam
elif [[ $umi == 'umi' ]]
then
    python ${baseDir}/add_umi_sam.py -s out.sam -o output.unsort.bam
else
    samtools view -1 -o output.unsort.bam out.sam
fi
which samtools
samtools sort -n --threads $SLURM_CPUS_ON_NODE -o output.dups.bam output.unsort.bam
java -Djava.io.tmpdir=./ -Xmx4g  -jar $PICARD/picard.jar FixMateInformation ASSUME_SORTED=TRUE SORT_ORDER=coordinate ADD_MATE_CIGAR=TRUE I=output.dups.bam O=${pair_id}.bam
samtools index ${pair_id}.bam
