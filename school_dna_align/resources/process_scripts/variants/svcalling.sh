#!/bin/bash
#svcalling.sh

usage() {
  echo "-h Help documentation for gatkrunner.sh"
  echo "-r  --Path to Reference Genome with the file genome.fa"
  echo "-p  --Prefix for output file name"
  echo "-b  --Bam File"
  echo "-n  --Reference Bam File"
  echo "Example: bash svcalling.sh -p prefix -r /path/GRCh38 -a gatk"
  exit 1
}
OPTIND=1 # Reset OPTIND
while getopts :r:p:b:i:n:a:h opt
do
    case $opt in
        r) index_path=$OPTARG;;
        p) pair_id=$OPTARG;;
        b) sbam=$OPTARG;;
        i) tumor=$OPTARG;;
        n) normal=$OPTARG;;
	a) method=$OPTARG;;
        h) usage;;
    esac
done
function join_by { local IFS="$1"; shift; echo "$*"; }

shift $(($OPTIND -1))
baseDir="`dirname \"$0\"`"


# Check for mandatory options
if [[ -z $pair_id ]] || [[ -z $index_path ]]; then
    usage
fi
if [[ -z $SLURM_CPUS_ON_NODE ]]
then
    SLURM_CPUS_ON_NODE=1
fi

if [[ -a "${index_path}/genome.fa" ]]
then
    reffa="${index_path}/genome.fa"
    dict="${index_path}/genome.dict"
else 
    echo "Missing Fasta File: ${index_path}/genome.fa"
    usage

fi

source /etc/profile.d/modules.sh	
module load samtools/1.6 bedtools/2.26.0 snpeff/4.3q vcftools/0.1.14
mkdir temp

if [[ $method == 'delly' ]]
then
    module load  delly2/v0.7.7-multi samtools/1.6 snpeff/4.3q
    if [[ -n ${normal} ]]
    then
	#RUN DELLY
	echo -e "${normal}\tcontrol"> samples.tsv
	echo -e "${tumor}\ttumor" >> samples.tsv
	delly2 call -t BND -o delly_translocations.bcf -q 30 -g ${reffa} ${sbam} ${normal}
	delly2 call -t DUP -o delly_duplications.bcf -q 30 -g ${reffa} ${sbam} ${normal}
	delly2 call -t INV -o delly_inversions.bcf -q 30 -g ${reffa} ${sbam} ${normal}
	delly2 call -t DEL -o delly_deletion.bcf -q 30 -g ${reffa} ${sbam} ${normal}
	delly2 call -t INS -o delly_insertion.bcf -q 30 -g ${reffa} ${sbam} ${normal}
	delly2 filter -t BND -o  delly_tra.bcf -f somatic -s samples.tsv delly_translocations.bcf
	delly2 filter -t DUP -o  delly_dup.bcf -f somatic -s samples.tsv delly_duplications.bcf
	delly2 filter -t INV -o  delly_inv.bcf -f somatic -s samples.tsv delly_inversions.bcf
	delly2 filter -t DEL -o  delly_del.bcf -f somatic -s samples.tsv delly_deletion.bcf
	delly2 filter -t INS -o  delly_ins.bcf -f somatic -s samples.tsv delly_insertion.bcf
    else
	#RUN DELLY
	delly2 call -t BND -o delly_translocations.bcf -q 30 -g ${reffa} ${sbam}
	delly2 call -t DUP -o delly_duplications.bcf -q 30 -g ${reffa} ${sbam}
	delly2 call -t INV -o delly_inversions.bcf -q 30 -g ${reffa} ${sbam}
	delly2 call -t DEL -o delly_deletion.bcf -q 30 -g ${reffa} ${sbam}
	delly2 call -t INS -o delly_insertion.bcf -q 30 -g ${reffa} ${sbam}
	delly2 filter -t BND -o  delly_tra.bcf -f germline delly_translocations.bcf
	delly2 filter -t DUP -o  delly_dup.bcf -f germline delly_duplications.bcf
	delly2 filter -t INV -o  delly_inv.bcf -f germline delly_inversions.bcf
	delly2 filter -t DEL -o  delly_del.bcf -f germline delly_deletion.bcf
	delly2 filter -t INS -o  delly_ins.bcf -f germline delly_insertion.bcf
    fi
    #MERGE DELLY AND MAKE BED
    bcftools concat -a -O v delly_dup.bcf delly_inv.bcf delly_tra.bcf delly_del.bcf delly_ins.bcf| vcf-sort -t temp > delly.vcf
    bgzip delly.vcf
    java -Xmx10g -jar $SNPEFF_HOME/snpEff.jar -no-intergenic -lof -c $SNPEFF_HOME/snpEff.config GRCh38.86 delly.vcf | java -jar $SNPEFF_HOME/SnpSift.jar filter " ( GEN[*].AD[1] >= 20 )" | bgzip > ${pair_id}.sv.vcf.gz
fi

if [[ $method == 'lumpy' ]]
then
    #MAKE FILES FOR LUMPY
    samtools sort -@ $SLURM_CPUS_ON_NODE -n -o namesort.bam ${sbam}
    samtools view -h namesort.bam | samblaster -M -a --excludeDups --addMateTags --maxSplitCount 2 --minNonOverlap 20 -d discordants.sam -s splitters.sam > temp.sam
    gawk '{ if ($0~"^@") { print; next } else { $10="*"; $11="*"; print } }' OFS="\t" splitters.sam | samtools  view -S -b - | samtools sort -o splitters.bam -
    gawk '{ if ($0~"^@") { print; next } else { $10="*"; $11="*"; print } }' OFS="\t" discordants.sam | samtools  view -S  -b - | samtools sort -o discordants.bam -
    #RUN LUMPY
    if [[ -n ${normal} ]]
    then
	samtools sort -@ $SLURM_CPUS_ON_NODE -n -o namesort.bam ${normal}
	samtools view -h namesort.bam | samblaster -M -a --excludeDups --addMateTags --maxSplitCount 2 --minNonOverlap 20 -d discordants.sam -s splitters.sam > temp.sam
	gawk '{ if ($0~"^@") { print; next } else { $10="*"; $11="*"; print } }' OFS="\t" splitters.sam | samtools  view -S -b - | samtools sort -o normal.splitters.bam -
	gawk '{ if ($0~"^@") { print; next } else { $10="*"; $11="*"; print } }' OFS="\t" discordants.sam | samtools  view -S  -b - | samtools sort -o normal.discordants.bam -
	speedseq sv -t $SLURM_CPUS_ON_NODE -o lumpy -R ${reffa} -B ${normal},${sbam} -D normal.discordants.bam,discordants.bam -S normal.splitters.bam,splitters.bam -x ${index_path}/exclude_alt.bed
    else
	speedseq sv -t $SLURM_CPUS_ON_NODE -o lumpy -R ${reffa} -B ${sbam} -D discordants.bam -S splitters.bam -x ${index_path}/exclude_alt.bed   
    fi
    java -Xmx10g -jar $SNPEFF_HOME/snpEff.jar -no-intergenic -lof -c $SNPEFF_HOME/snpEff.config GRCh38.86 lumpy.sv.vcf.gz | java -jar $SNPEFF_HOME/SnpSift.jar filter " ( GEN[*].DV >= 20 )" | bgzip > ${pair_id}.sv.vcf.gz
fi
