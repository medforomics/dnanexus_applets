FROM ubuntu:16.04
LABEL Author="Jeremy Mathews" \
      Maintainer="b.cantarel@gmail.com"

# install additional requirements
RUN apt-get update && apt-get install -y \
   wget \
   unzip \
   python3-pip \
   git

# Make destination and work directory
RUN mkdir -p /opt;
RUN mkdir -p /opt/bin;
#ENV http_proxy http://proxy.swmed.edu:3128/
#ENV https_proxy http://proxy.swmed.edu:3128/

# Install cutadapt
RUN pip3 install cutadapt==1.9.1

# Install trim_galore
RUN cd /opt; wget https://github.com/ComputationalSystemsBiology/EoulsanDockerFiles/raw/master/TrimAdapt/trim_galore_v0.4.1.zip; \
    unzip trim_galore_v0.4.1.zip; rm trim_galore_v0.4.1.zip; \
    ln -s /opt/trim_galore_zip/trim_galore /usr/local/bin/trim_galore;

# Install Scripts
RUN mkdir -p /project/PHG/PHG_Clinical; \
    cd /project/PHG/PHG_Clinical; \
    git clone -b version_0.5.9 --single-branch https://github.com/bcantarel/genomeseer.git; \
    cd genomeseer; \
    git submodule sync --recursive; git submodule update --init --recursive; \
    cp -r process_scripts/preproc_fastq/* /usr/local/bin/;

ENV PATH "$PATH:/usr/local/bin"

WORKDIR /data/
