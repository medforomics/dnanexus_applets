#!/bin/bash
#annotvcf.sh

usage() {
  echo "-h Help documentation for gatkrunner.sh"
  echo "-r  --Reference Genome: GRCh38 or GRCm38"
  echo "-p  --Prefix for output file name"
  echo "-v  --VCF File"
  echo "Example: bash hisat.sh -p prefix -r /path/GRCh38 -v vcffile"
  exit 1
}
OPTIND=1 # Reset OPTIND
while getopts :r:v:p:h opt
do
    case $opt in
        r) index_path=$OPTARG;;
        p) pair_id=$OPTARG;;
	v) unionvcf=$OPTARG;;
        h) usage;;
    esac
done

shift $(($OPTIND -1))

source /etc/profile.d/modules.sh
module load bedtools/2.26.0 samtools/1.6 snpeff/4.3q

if [[ $index_path == '/project/shared/bicf_workflow_ref/human/GRCh38/hisat_index' ]]
then
    index_path='/project/shared/bicf_workflow_ref/human/GRCh38'
fi

if  [[ $index_path == '/project/shared/bicf_workflow_ref/human/GRCh38' ]] 
then
    tabix -f ${unionvcf}
    bcftools annotate -Oz -a ${index_path}/gnomad.txt.gz -h ${index_path}/gnomad.header -c CHROM,POS,REF,ALT,GNOMAD_HOM,GNOMAD_AF,AF_POPMAX,GNOMAD_HG19_VARIANT -o ${pair_id}.gnomad.vcf.gz ${unionvcf}
    tabix ${pair_id}.gnomad.vcf.gz
    bcftools annotate -Oz -a ${index_path}/oncokb_hotspot.txt.gz -o ${pair_id}.oncohotspot.vcf.gz -h ${index_path}/oncokb_hotspot.header -c CHROM,FROM,TO,OncoKB_REF,OncoKB_ALT,Gene,OncoKB_ProteinChange,OncoKB_AF,OncoTree_Tissue,OncoTree_MainType,OncoTree_Code,OncoKBHotspot ${pair_id}.gnomad.vcf.gz
    tabix ${pair_id}.oncohotspot.vcf.gz
    bcftools annotate -Oz -a ${index_path}/repeat_regions.bed.gz -o ${pair_id}.repeat.vcf.gz --columns CHROM,FROM,TO,RepeatType -h /project/shared/bicf_workflow_ref/RepeatType.header ${pair_id}.oncohotspot.vcf.gz
    java -Xmx10g -jar $SNPEFF_HOME/snpEff.jar -no-downstream -no-upstream -no-intergenic -lof -c $SNPEFF_HOME/snpEff.config GRCh38.86 ${pair_id}.repeat.vcf.gz | java -jar $SNPEFF_HOME/SnpSift.jar annotate -id ${index_path}/dbSnp.vcf.gz -  | java -jar $SNPEFF_HOME/SnpSift.jar annotate -info CLNSIG,CLNDSDB,CLNDSDBID,CLNDBN,CLNREVSTAT,CLNACC ${index_path}/clinvar.vcf.gz - | java -jar $SNPEFF_HOME/SnpSift.jar annotate -info CNT ${index_path}/cosmic.vcf.gz - | java -Xmx10g -jar $SNPEFF_HOME/SnpSift.jar dbnsfp -v -db ${index_path}/dbNSFP.txt.gz - | bgzip > ${pair_id}.annot.vcf.gz
    tabix ${pair_id}.annot.vcf.gz
else 
    if [[ $index_path == '/project/shared/bicf_workflow_ref/mouse/GRCm38' ]]
    then
	snpeffvers='GRCm38.86'
    elif [[ $index_path == '/project/shared/bicf_workflow_ref/human/GRCh37' ]]
    then
	snpeffvers='GRCh37.75'
    fi
    java -Xmx10g -jar $SNPEFF_HOME/snpEff.jar -no-intergenic -lof -c $SNPEFF_HOME/snpEff.config ${snpeffvers} ${unionvcf} |bgzip > ${pair_id}.annot.vcf.gz
    tabix ${pair_id}.annot.vcf.gz
fi
