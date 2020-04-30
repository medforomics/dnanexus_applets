FROM ubuntu:16.04
LABEL Author="Jeremy Mathews" \
      Maintainer="b.cantarel@gmail.com"

# install additional requirements
RUN apt-get update; apt-get install -y build-essential checkinstall; \
    apt-get install -y libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev zlib1g-dev liblzma-dev libcurl4-gnutls-dev libncurses5-dev wget unzip git default-jre default-jdk r-base;

# Make destination and work directory
RUN mkdir -p /opt;
RUN mkdir -p /opt/bin;
#ENV http_proxy http://proxy.swmed.edu:3128/
#ENV https_proxy http://proxy.swmed.edu:3128/

# Install Python
RUN cd /usr/src; wget https://www.python.org/ftp/python/2.7.17/Python-2.7.17.tgz; \
    tar -zxvf Python-2.7.17.tgz; rm Python-2.7.17.tgz; \
    cd Python-2.7.17; \
    ./configure --enable-optimizations; \
    make altinstall;
RUN cd /usr/local/bin; \
    mv python2.7 python;

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
    cp bin/* /opt/bin;

# Install FastQC
RUN cd /opt/bin; wget http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.5.zip; \
    unzip fastqc_v0.11.5.zip; rm fastqc_v0.11.5.zip;

# Install Picard
RUN cd /opt/bin; wget https://github.com/broadinstitute/picard/releases/download/2.21.7/picard.jar; \
    cp -R /opt/bin/* /usr/local/bin/; \
    chmod +x /usr/local/bin/picard.jar; \
    chmod 755 /usr/local/bin/FastQC/fastqc;
ENV PICARD "/usr/local/bin"
ENV PATH "$PATH:/usr/local/bin/FastQC"

# Install NGSCheckMate
RUN cd /opt/bin; wget https://github.com/parklab/NGSCheckMate/archive/v1.0.0.tar.gz; \
    tar xvfz v1.0.0.tar.gz; rm v1.0.0.tar.gz; \
    cd NGSCheckMate-1.0.0; \
    rm README.md LICENSE Documentation.pdf test_datafiles.txt; \
    cp -R * /usr/local/bin/;

# Install MSIsensor-pro
RUN cd /opt/bin; git clone --branch 1.0.a https://github.com/xjtu-omics/msisensor-pro; \
    cd msisensor-pro/cpp; \
    make; \
    mv msisensor-pro /usr/local/bin/;

# Install Scripts
RUN cd /opt; git clone -b version_0.5.4 --single-branch https://github.com/bcantarel/genomeseer.git; \
    cd genomeseer; \
    git submodule sync --recursive; git submodule update --init --recursive; \
    cp -r process_scripts/alignment/* /usr/local/bin/; \
    cp -r scripts/* /usr/local/bin/;

ENV PATH "$PATH:/usr/local/bin"

WORKDIR /data/
