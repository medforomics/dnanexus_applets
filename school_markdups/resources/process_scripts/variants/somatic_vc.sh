#!/bin/bash
#run_somatic_caller.sh


usage(){
  echo "-h --Help documentation for run_somatic_caller.sh"
  echo "-a --Somatic Workflow Method: strelka2, virmid, speedseq, mutect2, varscan, shimmer, lancet"
  echo "-r  --Path to Reference Genome with the file genome.fa"
  echo "-n --Normal"
  echo "-t --Tumor"
  echo "-p -- PairID"
  echo "-x --NormalID"
  echo "-y --TumorID"
  echo "-i --NormalBAM used for Mantra in the case of UMI consensus"
  echo "-j --TumorBAM used for Mantra in the case of UMI consensus"
  echo "-b --TargetBed"
  
  echo "Example: bash somatic_vc.sh -a strelka2 -p subj1 -y ORD1_N_panel1385 -y ORD1_T_panel138 -n ORD1_N_panel1385.final.bam -t ORD1_T_panel1385.final.bam"
  exit 1
}

OPTIND=1 # Reset OPTIND
while getopts :n:t:p:r:x:y:i:j:a:b:h opt
do
    case $opt in 
      r) index_path=$OPTARG;;
      x) tid=$OPTARG;;
      y) nid=$OPTARG;;
      p) pair_id=$OPTARG;;
      n) normal=$OPTARG;;
      t) tumor=$OPTARG;;
      i) mnormal=$OPTARG;;
      j) mtumor=$OPTARG;;
      a) algo=$OPTARG;;
      b) tbed=$OPTARG;; 
      h) usage;;
    esac
done

shift $(($OPTIND -1))

#Check for mandatory options
if [[ -z $normal ]] || [[ -z $tumor ]] || [[ -z $algo ]]; then
    echo $normal $tumor $algo
    usage
fi 
if [[ -z $SLURM_CPUS_ON_NODE ]] 
  then 
    SLURM_CPUS_ON_NODE=1
fi
#pair_id=${tid}_${nid}
if [[ -z $mtumor ]]
then
    mtumor=tumor
    mnormal=normal
fi

if [[ -a "${index_path}/genome.fa" ]]
then
    reffa="${index_path}/genome.fa"
    dict="${index_path}/genome.dict"
else 
    echo "Missing Fasta File: ${index_path}/genome.fa"
    usage
fi
if [[ -a "${index_path}/dbSnp.vcf.gz" ]]
then
    dbsnp="${index_path}/dbSnp.vcf.gz"
else 
    echo "Missing dbSNP File: ${index_path}/dbSnp.vcf.gz"
    usage
fi

if [[ -a "${index_path}/cosmic.vcf.gz" ]]
then
    cosmic=${index_path}/cosmic.vcf.gz
else 
    echo "Missing InDel File: ${index_path}/cosmic.vcf.gz"
    usage
fi
baseDir="`dirname \"$0\"`"

source /etc/profile.d/modules.sh
module load htslib/gcc/1.8

if [ $algo == 'strelka2' ]
  then
    module load strelka/2.9.10 manta/1.3.1 samtools/gcc/1.8 snpeff/4.3q vcftools/0.1.14
    mkdir manta strelka
    configManta.py --normalBam ${normal} --tumorBam ${tumor} --referenceFasta ${reffa} --runDir manta
    manta/runWorkflow.py -m local -j 8
    configureStrelkaSomaticWorkflow.py --normalBam ${normal} --tumorBam ${tumor} --referenceFasta ${reffa} --targeted --indelCandidates manta/results/variants/candidateSmallIndels.vcf.gz --runDir strelka
    strelka/runWorkflow.py -m local -j 8
    vcf-concat strelka/results/variants/*.vcf.gz | vcf-annotate -n --fill-type -n |vcf-sort |java -jar $SNPEFF_HOME/SnpSift.jar filter "(GEN[*].DP >= 10)" | perl -pe "s/TUMOR/${tid}/g" | perl -pe "s/NORMAL/${nid}/g" |bgzip > ${pair_id}.strelka2.vcf.gz
fi
if [ $algo == 'virmid' ]
  then 
    module load virmid/1.2 samtools/gcc/1.8 vcftools/0.1.14
    virmid -R ${reffa} -D ${tumor} -N ${normal} -s ${cosmic} -t $SLURM_CPUS_ON_NODE -M 2000 -c1 10 -c2 10
    perl $baseDir/addgt_virmid.pl ${tumor}.virmid.som.passed.vcf
    perl $baseDir/addgt_virmid.pl ${tumor}.virmid.loh.passed.vcf
    module rm java/oracle/jdk1.7.0_51
    module load snpeff/4.3q
    vcf-concat *gt.vcf | vcf-sort | vcf-annotate -n --fill-type -n | java -jar $SNPEFF_HOME/SnpSift.jar filter '((NDP >= 10) & (DDP >= 10))' | perl -pe "s/TUMOR/${tid}/g" | perl -pe "s/NORMAL/${nid}/g" | bgzip > ${pair_id}.virmid.vcf.gz
elif [ $algo == 'mutect2' ]
then
  gatk4_dbsnp=${index_path}/clinseq_prj/dbSnp.gatk4.vcf.gz
  user=$USER
  module load gatk/4.x singularity/2.6.1 picard/2.10.3
  mkdir /tmp/${user}
  export TMP_HOME=/tmp/${user}
  java -XX:ParallelGCThreads=$SLURM_CPUS_ON_NODE -Djava.io.tmpdir=./ -Xmx16g  -jar $PICARD/picard.jar CollectSequencingArtifactMetrics I=${tumor} O=artifact_metrics.txt R=${reffa}
  singularity exec -H /tmp/${user} /project/apps/singularity-images/gatk4/gatk-4.x.simg /gatk/gatk --java-options "-Xmx20g" Mutect2 -R ${reffa} -A FisherStrand -A QualByDepth -A StrandArtifact -A DepthPerAlleleBySample -I ${tumor} -tumor ${tid} -I ${normal} -normal ${nid} --output ${tid}.mutect.vcf
  singularity exec -H /tmp/${user} /project/apps/singularity-images/gatk4/gatk-4.x.simg /gatk/gatk --java-options "-Xmx20g" FilterMutectCalls -V ${tid}.mutect.vcf -O ${tid}.mutect.filt.vcf
  module load snpeff/4.3q samtools/gcc/1.8 vcftools/0.1.14
  vcf-sort ${tid}.mutect.filt.vcf | vcf-annotate -n --fill-type | java -jar $SNPEFF_HOME/SnpSift.jar filter -p '(GEN[*].DP >= 10)' | bgzip > ${pair_id}.mutect.vcf.gz
elif [ $algo == 'varscan' ]
then
  module load samtools/gcc/1.8 VarScan/2.4.2 vcftools/0.1.14
  module rm java/oracle/jdk1.7.0_51
  module load snpeff/4.3q 
  samtools mpileup -C 50 -f ${reffa} $tumor > t.mpileup
  samtools mpileup -C 50 -f ${reffa} $normal > n.mpileup
  VarScan somatic n.mpileup t.mpileup vscan --output-vcf 1
  VarScan copynumber n.mpileup t.mpileup vscancnv
  vcf-concat vscan*.vcf | vcf-sort | vcf-annotate -n --fill-type -n | java -jar $SNPEFF_HOME/SnpSift.jar filter '((exists SOMATIC) & (GEN[*].DP >= 10))' | perl -pe "s/TUMOR/${tid}/" | perl -pe "s/NORMAL/${nid}/g" | bgzip >  ${pair_id}.varscan.vcf.gz
elif [ $algo == 'shimmer' ]
then
    module load shimmer/0.1.1 samtools/gcc/1.8  vcftools/0.1.14
    shimmer.pl --minqual 25 --ref ${reffa} ${normal} ${tumor} --outdir shimmer 2> shimmer.err
    perl $baseDir/add_readct_shimmer.pl
    module rm java/oracle/jdk1.7.0_51
    module load snpeff/4.3q
    vcf-annotate -n --fill-type shimmer/somatic_diffs.readct.vcf | java -jar $SNPEFF_HOME/SnpSift.jar filter '(GEN[*].DP >= 10)' | perl -pe "s/TUMOR/${tid}/" | perl -pe "s/NORMAL/${nid}/g" | bgzip > ${pair_id}.shimmer.vcf.gz
fi


