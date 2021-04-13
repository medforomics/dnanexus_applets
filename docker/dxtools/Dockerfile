FROM ubuntu:16.04
LABEL Author="Brandi Cantarel" \
      Maintainer="b.cantarel@gmail.com"

# install additional requirements
RUN apt-get update; apt-get install -y build-essential checkinstall; \
    apt-get install -y make python-setuptools python-pip python-virtualenv python-dev gcc g++ cmake libboost-all-dev libcurl4-openssl-dev zlib1g-dev libbz2-dev flex bison openssl libssl-dev autoconf git curl wget

RUN mkdir -p /opt

RUN cd /opt; wget https://dnanexus-sdk.s3.amazonaws.com/dx-toolkit-v0.306.0-ubuntu-16.04-amd64.tar.gz; tar xvfz dx-toolkit-v0.306.0-ubuntu-16.04-amd64.tar.gz;

RUN cd /opt; wget https://dnanexus-sdk.s3.amazonaws.com/dnanexus-upload-agent-1.5.33-linux.tar.gz; tar -xzf dnanexus-upload-agent-*-linux.tar.gz; cp dnanexus-upload-agent-*-linux/ua /usr/bin/

ENV isdocker 1
ENV http_proxy http://proxy.swmed.edu:3128/
ENV https_proxy http://proxy.swmed.edu:3128/

WORKDIR /data/

ENTRYPOINT ["/bin/bash", "-c", "source /opt/dx-toolkit/environment && \"$@\"", "-s"]
