#!/bin/bash

perl -pi -e 's/version_0.5.30/version_0.5.30/g' docker/*/Dockerfile */dxapp.json */src/*.sh build_docker.sh
cd docker
ls | awk '{print "docker build --tag",$1":0.5.30",$1}' |sh
ls | awk '{print "docker tag",$1":0.5.30 goalconsortium/"$1":0.5.30"}' |sh
ls | awk '{print "docker push goalconsortium/"$1":0.5.30"}' |sh
cd ..

source /Users/bcantarel/utsw/dnanexus/dx-toolkit/environment
dx build -f trim_galore
dx build -f dalign
dx build -f markdups
dx build -f dna_bamqc
dx build -f snv_indel_calling
dx build -f sv_calling
dx build -f variant_profiling
dx build -f geneabund
dx build -f star_fusion
dx build -f rna_bamqc
dx build -f integratevcf

#dx build -f rnaalign

