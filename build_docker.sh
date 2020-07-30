#!/bin/bash

cd docker
ls | awk '{print "docker build --tag",$1":0.5.29",$1}' |sh
ls | awk '{print "docker tag",$1":0.5.29 goalconsortium/"$1":0.5.29"}' |sh
ls | awk '{print "docker push goalconsortium/"$1":0.5.29"}' |sh

source /Users/bcantarel/utsw/dnanexus/dx-toolkit/environment
dx build -f trim_galore
dx build -f align_markdups
dx build -f snv_indel_calling
dx build -f sv_calling
dx build -f variant_profiling

dx build -f geneabund
dx build -f star_fusion
dx build -f rna_bamqc


dx build -f rnaalign
dx build -f integratevcf
