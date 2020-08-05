#!/bin/bash


perl -pi -e 's/version_0.5.36/version_0.5.40/g' docker/*/Dockerfile
perl -pi -e 's/version_0.5.39/version_0.5.40/g' docker/*/Dockerfile

cd docker
ls | awk '{print "docker build --tag",$1":0.5.40",$1}' |sh
ls | awk '{print "docker tag",$1":0.5.40 goalconsortium/"$1":0.5.36"}' |sh
ls | awk '{print "docker push goalconsortium/"$1":0.5.40"}' |sh
cd ..

perl -pi -e 's/0.5.36/0.5.36/g' */dxapp.json */src/*.sh build_docker.sh
source /Users/bcantarel/utsw/dnanexus/dx-toolkit/environment
ls */dxapp.json | awk -F '/' '{print "dx build -f",$1}' |sh
dx build -f dalign
dx build -f dna_bamqc
dx build -f gatkbam
dx build -f geneabund
dx build -f integratevcf
dx build -f markdups
dx build -f rna_bamqc
dx build -f rnaalign
dx build -f snv_indel_calling
dx build -f star_fusion
dx build -f sv_calling
dx build -f trim_galore
dx build -f variant_profiling

