#!/bin/bash

perl -pi -e 's/0.5.30/0.5.33/g' docker/*/Dockerfile */dxapp.json */src/*.sh build_docker.sh
cd docker
ls | awk '{print "docker build --tag",$1":0.5.33",$1}' |sh
ls | awk '{print "docker tag",$1":0.5.33 goalconsortium/"$1":0.5.33"}' |sh
ls | awk '{print "docker push goalconsortium/"$1":0.5.33"}' |sh
cd ..

source /Users/bcantarel/utsw/dnanexus/dx-toolkit/environment
ls */dxapp.json | awk -F '/' '{print "build -f",$1}' |sh
build -f dalign
build -f dna_bamqc
build -f gatkbam
build -f geneabund
build -f integratevcf
build -f markdups
build -f rna_bamqc
build -f rnaalign
build -f snv_indel_calling
build -f star_fusion
build -f sv_calling
build -f trim_galore
build -f variant_profiling

