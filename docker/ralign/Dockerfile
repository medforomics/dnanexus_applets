FROM ubuntu:16.04
LABEL Author="Jeremy Mathews" \
      Maintainer="b.cantarel@gmail.com"

# install additional requirements
RUN apt-get update; apt-get install -y build-essential checkinstall; \
    apt-get install -y libreadline-gplv2-dev cmake patch libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev zlib1g-dev liblzma-dev libcurl4-gnutls-dev libncurses5-dev wget unzip git default-jre default-jdk;


# Make destination and work directory
RUN mkdir -p /opt;
RUN mkdir -p /opt/bin;
#ENV http_proxy http://proxy.swmed.edu:3128/
#ENV https_proxy http://proxy.swmed.edu:3128/

# Install Python
RUN cd /usr/src; wget https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz; \
    tar -zxvf Python-2.7.18.tgz; rm Python-2.7.18.tgz; \
    cd Python-2.7.18; \
    ./configure --enable-optimizations; \
    make altinstall;
RUN cd /usr/local/bin; \
    mv python2.7 python;
RUN python -m ensurepip --default-pip; \
    python -m pip install pysam argparse

# Install SamTools
RUN cd /opt; wget https://github.com/samtools/samtools/releases/download/1.10/samtools-1.10.tar.bz2; \
    tar -vxjf samtools-1.10.tar.bz2; rm samtools-1.10.tar.bz2; \
    cd samtools-1.10; \
    ./configure; make; make install; \
    cp samtools /opt/bin;

# Install Bedtools
RUN cd /opt; wget https://github.com/arq5x/bedtools2/releases/download/v2.29.2/bedtools-2.29.2.tar.gz; \
    tar xvfz bedtools-2.29.2.tar.gz; rm bedtools-2.29.2.tar.gz; \
    cd bedtools2; \
    make; \
    cp -r bin/* /opt/bin;

# Install Picard + FGBio
RUN cd /opt/bin; wget https://github.com/broadinstitute/picard/releases/download/2.21.7/picard.jar; \
    cp -R /opt/bin/* /usr/local/bin/; \
    chmod +x /usr/local/bin/picard.jar;
ENV PICARD "/usr/local/bin"

# Install HISAT2
RUN cd /opt; wget ftp://ftp.ccb.jhu.edu/pub/infphilo/hisat2/downloads/hisat2-2.1.0-source.zip; \
    unzip hisat2-2.1.0-source.zip; rm hisat2-2.1.0-source.zip; \
    cd hisat2-2.1.0; \
    make; \
    cp -r hisat* /usr/local/bin;

# Install STAR
RUN cd /opt; wget https://github.com/alexdobin/STAR/archive/2.7.2b.tar.gz; \
    tar xvfz 2.7.2b.tar.gz; rm 2.7.2b.tar.gz; \
    cd STAR-2.7.2b/source; \
    make STAR; \
    cp -r * /usr/local/bin;

# Install STARFusion
RUN cd /opt; wget https://github.com/STAR-Fusion/STAR-Fusion/releases/download/STAR-Fusion-v1.8.1/STAR-Fusion-v1.8.1.FULL.tar.gz; \
    tar -zxvf STAR-Fusion-v1.8.1.FULL.tar.gz; rm STAR-Fusion-v1.8.1.FULL.tar.gz; \
    cd STAR-Fusion-v1.8.1; \
    cp -r * /usr/local/bin;

# Install Scripts
RUN cd /opt; git clone -b version_0.5.9 --single-branch https://github.com/bcantarel/genomeseer.git; \
    cd genomeseer; \
    git submodule sync --recursive; git submodule update --init --recursive; \
    cp -r process_scripts/alignment/* /usr/local/bin/;

ENV PATH "$PATH:/usr/local/bin"

WORKDIR /data/
