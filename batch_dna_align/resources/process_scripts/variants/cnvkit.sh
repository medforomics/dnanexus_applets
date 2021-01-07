#!/bin/bash
#cnvkit.sh

usage() {
  echo "-h  --Help documentation for markdups.sh"
  echo "-b  --BAM file"
  echo "-p  --Prefix for output file name"
  echo "-n  --Panel of Normal cnn file"
  echo "-t  --Target and Antitarget prefix"
  echo "Example: bash cnvkit.sh -p prefix -b file.bam"
  exit 1
}
OPTIND=1 # Reset OPTIND
while getopts :b:p:n:t:c:uh opt
do
    case $opt in
        b) sbam=$OPTARG;;
        p) pair_id=$OPTARG;;
	n) normals=$OPTARG;;
	t) targets=$OPTARG;;
	c) capture=$OPTARG;;
	u) umi='umi';;
        h) usage;;
    esac
done

shift $(($OPTIND -1))

index_path='/project/shared/bicf_workflow_ref/human/GRCh38/clinseq_prj'

# Check for mandatory options
if [[ -z $pair_id ]] || [[ -z $sbam ]]; then
    usage
fi
if [[ -z $SLURM_CPUS_ON_NODE ]]
then
    SLURM_CPUS_ON_NODE=1
fi
baseDir="`dirname \"$0\"`"

if [[ $capture == "${index_path}/UTSWV2.bed" ]]
then 
    normals="${index_path}/UTSWV2.normals.cnn"
    targets="${index_path}/UTSWV2.cnvkit_"
    if [[ $umi == 'umi' ]]
    then
	normals="${index_path}/UTSWV2.uminormals.cnn"
    fi
elif [[ $capture == "${index_path}/UTSWV2_2.panelplus.bed" ]]
then
    normals="${index_path}/panelofnormals.panel1385V2_2.cnn"
    targets="${index_path}/panel1385V2-2.cnvkit_"
elif [[ $capture == "${index_path}/hemepanelV3.bed" ]]
then
    normals="${index_path}/hemepanelV3.panelofnormals.cnn"
    targets="${index_path}/hemepanelV3.cnvkit_"
fi

echo "${targets}targets.bed"
echo "${targets}antitargets.bed"

source /etc/profile.d/modules.sh
module load cnvkit/0.9.5 bedtools/2.26.0
unset DISPLAY
cnvkit.py coverage ${sbam} ${targets}targets.bed -o ${pair_id}.targetcoverage.cnn
cnvkit.py coverage ${sbam} ${targets}antitargets.bed -o ${pair_id}.antitargetcoverage.cnn
cnvkit.py fix ${pair_id}.targetcoverage.cnn ${pair_id}.antitargetcoverage.cnn ${normals} -o ${pair_id}.cnr
cnvkit.py segment ${pair_id}.cnr -o ${pair_id}.cns
cnvkit.py call ${pair_id}.cns -o ${pair_id}.call.cns
cnvkit.py scatter ${pair_id}.cnr -s ${pair_id}.call.cns -t --segment-color "blue" -o ${pair_id}.cnv.scatter.pdf
cut -f 1,2,3 ${pair_id}.call.cns | grep -v chrom | bedtools intersect -wao -b /project/shared/bicf_workflow_ref/human/GRCh38/cytoBand.txt -a stdin |cut -f 1,2,3,7 >  ${pair_id}.cytoband.bed
perl $baseDir/filter_cnvkit.pl *.call.cns
