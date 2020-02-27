FROM ubuntu:16.04
LABEL Author="Jeremy Mathews" \
      Maintainer="b.cantarel@gmail.com"

# install additional requirements
RUN apt-get update; apt-get install -y build-essential checkinstall; \
    apt-get install -y libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev zlib1g-dev liblzma-dev libcurl4-gnutls-dev libncurses5-dev libffi-dev wget unzip git default-jre default-jdk r-base;

# Make destination and work directory
RUN mkdir -p /opt;
RUN mkdir -p /opt/bin;
#ENV http_proxy http://proxy.swmed.edu:3128/
#ENV https_proxy http://proxy.swmed.edu:3128/

# Install Python
RUN cd /usr/src; wget https://www.python.org/ftp/python/3.8.1/Python-3.8.1.tgz; \
    tar -zxvf Python-3.8.1.tgz; rm Python-3.8.1.tgz; \
    cd Python-3.8.1; \
    ./configure --enable-optimizations; \
    make altinstall;
RUN cd /usr/local/bin; \
    mv python3.8 python;
RUN python -m ensurepip --default-pip;

# Install SamTools + BCFTools + htslib
RUN cd /opt; wget https://github.com/samtools/htslib/releases/download/1.9/htslib-1.9.tar.bz2; \
    tar -vxjf htslib-1.9.tar.bz2; rm htslib-1.9.tar.bz2; \
    cd htslib-1.9; \
    ./configure; make; make install; \
    cp -r htslib /opt/bin;
RUN cd /opt; wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2; \
    tar -vxjf samtools-1.9.tar.bz2; rm samtools-1.9.tar.bz2; \
    cd samtools-1.9; \
    ./configure; make; make install; \
    cp -r samtools /opt/bin;
RUN cd /opt; wget https://github.com/samtools/bcftools/releases/download/1.9/bcftools-1.9.tar.bz2; \
    tar -vxjf bcftools-1.9.tar.bz2; rm bcftools-1.9.tar.bz2; \
    cd bcftools-1.9; \
    ./configure; make; make install; \
    cp -r bcftools /opt/bin;

# Install Bedtools
RUN cd /opt; wget https://github.com/arq5x/bedtools2/releases/download/v2.29.2/bedtools-2.29.2.tar.gz; \
    tar xvfz bedtools-2.29.2.tar.gz; rm bedtools-2.29.2.tar.gz; \
    cd bedtools2; \
    make; \
    cp bin/* /opt/bin;

# Install VCFTools
RUN cd /opt; wget https://github.com/vcftools/vcftools/releases/download/v0.1.14/vcftools-0.1.14.tar.gz; \
    tar xvfz vcftools-0.1.14.tar.gz; rm vcftools-0.1.14.tar.gz; \
    cd vcftools-0.1.14; \
    ./configure; make; make install;

# Install snpEff
RUN cd /opt/bin; wget https://sourceforge.net/projects/snpeff/files/snpEff_v4_3t_core.zip; \
    unzip snpEff_v4_3t_core.zip; rm snpEff_v4_3t_core.zip; \
    wget https://sourceforge.net/projects/snpeff/files/databases/v4_3/snpEff_v4_3_GRCh38.92.zip; \
    unzip snpEff_v4_3_GRCh38.92.zip; rm snpEff_v4_3_GRCh38.92.zip;
RUN cp -R /opt/bin/* /usr/local/bin/; \
    chmod +x /usr/local/bin/snpEff/snpEff.jar;
ENV SNPEFF "/usr/local/bin/snpEff"

# Install CNVkit
RUN R -e "install.packages(c('BiocManager', 'DNAcopy'), repos='https://cran.rstudio.com')";
RUN cd /opt/bin; wget https://github.com/etal/cnvkit/archive/v0.9.5.tar.gz; \
    tar xvfz v0.9.5.tar.gz; rm v0.9.5.tar.gz; \
    cd cnvkit-0.9.5; \
    python -m pip install -e .;
RUN cd /opt/bin/cnvkit-0.9.5; \
    cp -R * /usr/local/bin/;

# Install Scripts
RUN cd /opt; git clone https://git.biohpc.swmed.edu/ngsclialab/clinseq_workflows.git; cd clinseq_workflows; \
    git submodule sync --recursive; git submodule update --init --recursive; \
    cp -r process_scripts/variants/* /usr/local/bin/;

ENV PATH "$PATH:/usr/local/bin"

WORKDIR /data/
