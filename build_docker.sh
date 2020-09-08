#!/bin/bash


perl -pi -e 's/version_1.0.3/version_1.0.4/g' docker/*/Dockerfile
perl -pi -e 's/1.0.3/1.0.4/g' */src/* */dxapp.json


cd docker
ls | awk '{print "docker build --tag",$1":1.0.4",$1}' |sh
ls | awk '{print "docker tag",$1":1.0.4 goalconsortium/"$1":1.0.4"}' |sh
ls | awk '{print "docker push goalconsortium/"$1":1.0.4"}' |sh
ls | awk '{print "docker run -v /var/run/docker.sock:/var/run/docker.sock -v /seqprg/singularity/:/output --privileged -t --rm quay.io/singularity/docker2singularity --name",$1,$1":1.0.4"}'|sh
cd ..

source /Users/bcantarel/utsw/dnanexus/dx-toolkit/environment
ls */dxapp.json | awk -F '/' '{print "dx build -f",$1}' |sh
