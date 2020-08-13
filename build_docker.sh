#!/bin/bash


perl -pi -e 's/version_0.5.40/version_1.0.0/g' docker/*/Dockerfile
perl -pi -e 's/0.5.40/1.0.0/g' */src/* */dxapp.json


cd docker
ls | awk '{print "docker build --tag",$1":1.0.0",$1}' |sh
ls | awk '{print "docker tag",$1":1.0.0 goalconsortium/"$1":1.0.0"}' |sh
ls | awk '{print "docker push goalconsortium/"$1":1.0.0"}' |sh
cd ..

source /Users/bcantarel/utsw/dnanexus/dx-toolkit/environment
ls */dxapp.json | awk -F '/' '{print "dx build -f",$1}' |sh
