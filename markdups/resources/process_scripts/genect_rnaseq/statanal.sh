#!/bin/bash
#rnaseqalign.sh

usage() {
  echo "-h Help documentation for hisat.sh"
  echo "-d  --DEA"
  echo "Example: bash statanal.sh"
  exit 1
}
OPTIND=1 # Reset OPTIND
while getopts :d:h opt
do
    case $opt in
        d) dea=$OPTARG;;
        h) usage;;
    esac
done

shift $(($OPTIND -1))
baseDir="`dirname \"$0\"`"

# Check for mandatory options
if [[ -z $SLURM_CPUS_ON_NODE ]]
then
    SLURM_CPUS_ON_NODE=1
fi
source /etc/profile.d/modules.sh

perl $baseDir/concat_cts.pl -o ./ *.cts
perl $baseDir/concat_fpkm.pl -o ./ *.fpkm.txt
perl $baseDir/concat_ctsum.pl -o ./ *.cts.summary
cp design.txt design.shiny.txt
cp geneset.gmt geneset.shiny.gmt

if [[ $dea == 'skip' ]]
then
    touch empty.png
    touch bg.rda
else
    module load R/3.2.1-intel
    Rscript  $baseDir/dea.R
    Rscript $baseDir/build_ballgown.R *_stringtie
    perl $baseDir/concat_edgeR.pl *.edgeR.txt
fi
