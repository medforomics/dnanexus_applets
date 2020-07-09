FROM ubuntu:16.04
LABEL Author="Jeremy Mathews" \
      Maintainer="b.cantarel@gmail.com"

# install additional requirements
RUN apt-get update; apt-get install -y build-essential checkinstall; \
    apt-get install -y libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev zlib1g-dev liblzma-dev libcurl4-gnutls-dev libncurses5-dev wget unzip git default-jre default-jdk r-base cmake patch gfortran hdf5-tools libboost-date-time-dev libboost-program-options-dev libboost-system-dev libboost-filesystem-dev libboost-iostreams-dev libhdf5-dev fort77 xorg-dev libblas-dev gcc-multilib gobjc++ aptitude texlive-latex-base libcairo2-dev;

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
RUN python -m ensurepip;

# Install SamTools
RUN cd /opt; wget https://github.com/samtools/samtools/releases/download/1.10/samtools-1.10.tar.bz2; \
    tar -vxjf samtools-1.10.tar.bz2; rm samtools-1.10.tar.bz2; \
    cd samtools-1.10; \
    ./configure; make; make install; \
    mv samtools /opt/bin;

# Install SamTools + BCFTools + htslib
RUN cd /opt; wget https://github.com/samtools/htslib/releases/download/1.10/htslib-1.10.tar.bz2; \
    tar -vxjf htslib-1.10.tar.bz2; rm htslib-1.10.tar.bz2; \
    cd htslib-1.10; \
    ./configure; make; make install; \
    mv htslib /opt/bin;
RUN cd /opt; wget https://github.com/samtools/samtools/releases/download/1.10/samtools-1.10.tar.bz2; \
    tar -vxjf samtools-1.10.tar.bz2; rm samtools-1.10.tar.bz2; \
    cd samtools-1.10; \
    ./configure; make; make install; \
    mv samtools /opt/bin;
RUN cd /opt; wget https://github.com/samtools/bcftools/releases/download/1.10/bcftools-1.10.tar.bz2; \
    tar -vxjf bcftools-1.10.tar.bz2; rm bcftools-1.10.tar.bz2; \
    cd bcftools-1.10; \
    ./configure; make; make install; \
    mv bcftools /opt/bin;

# Install Bedtools
RUN cd /opt; wget https://github.com/arq5x/bedtools2/releases/download/v2.29.2/bedtools-2.29.2.tar.gz; \
    tar xvfz bedtools-2.29.2.tar.gz; rm bedtools-2.29.2.tar.gz; \
    cd bedtools2; \
    make; \
    mv bin/* /opt/bin;

# Install FastQC
RUN cd /opt/bin; wget http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.5.zip; \
    unzip fastqc_v0.11.5.zip; rm fastqc_v0.11.5.zip;

# Install snpEff
RUN cd /opt/bin; wget https://sourceforge.net/projects/snpeff/files/snpEff_v4_3t_core.zip; \
    unzip snpEff_v4_3t_core.zip; rm snpEff_v4_3t_core.zip; \
    cd snpEff; \
    wget https://sourceforge.net/projects/snpeff/files/databases/v4_3/snpEff_v4_3_GRCh38.92.zip; \
    unzip snpEff_v4_3_GRCh38.92.zip; rm snpEff_v4_3_GRCh38.92.zip;

# Install Picard
RUN cd /opt/bin; wget https://github.com/broadinstitute/picard/releases/download/2.21.7/picard.jar; \
    mv /opt/bin/* /usr/local/bin/; \
    chmod +x /usr/local/bin/picard.jar; \
    chmod 755 /usr/local/bin/FastQC/fastqc; \
    chmod +x /usr/local/bin/snpEff/snpEff.jar; \
    chmod +x /usr/local/bin/snpEff/SnpSift.jar
ENV PICARD "/usr/local/bin"
ENV PATH "$PATH:/usr/local/bin/FastQC"
ENV SNPEFF_HOME "/usr/local/bin/snpEff"

# Install CNVkit
RUN apt-get install -y r-base;
RUN cd /opt; wget https://cran.r-project.org/src/base/R-3/R-3.3.2.tar.gz; \
    tar xvfz R-3.3.2.tar.gz; rm R-3.3.2.tar.gz; \
    cd R-3.3.2; \
    ./configure --with-x=yes --enable-R-shlib=yes --with-cairo=yes; \
    make; make install;
RUN R -e "install.packages('BiocManager', repos='https://cran.rstudio.com')";
RUN R -e "BiocManager::install('DNAcopy')"
RUN pip install numpy==1.16.6; pip install scipy==1.2.3; pip install pandas==0.24.2; pip install matplotlib==2.2.5; pip install reportlab; pip install biopython==1.76; pip install pyfaidx; pip install pysam; pip install pyvcf;
RUN cd /opt/bin; git clone -b v0.9.6 --single-branch https://github.com/etal/cnvkit; \
    cd cnvkit/; \
    pip install future; pip install futures; pip install networkx; pip install joblib; pip install cython; pip install pomegranate; \
    cd /opt/bin/cnvkit/; \
    mv * /usr/local/bin/;

# Install ITDSeek
RUN cd /opt/bin; wget https://github.com/tommyau/itdseek/archive/v1.2.tar.gz; \
    tar xvfz v1.2.tar.gz; rm v1.2.tar.gz; \
    cd itdseek-1.2; \
    mv *.pl /usr/local/bin/;

# Install NGSCheckMate
RUN cd /opt/bin; wget https://github.com/parklab/NGSCheckMate/archive/v1.0.0.tar.gz; \
    tar xvfz v1.0.0.tar.gz; rm v1.0.0.tar.gz; \
    cd NGSCheckMate-1.0.0; \
    rm README.md LICENSE Documentation.pdf test_datafiles.txt; \
    mv * /usr/local/bin/;
ENV NCM_HOME="/usr/local/bin"

# Install MSIsensor-pro
RUN cd /opt/bin; git clone --branch 1.0.a https://github.com/xjtu-omics/msisensor-pro; \
    cd msisensor-pro/cpp; \
    make; \
    mv msisensor-pro /usr/local/bin/;

# Install BAM-ReadCount
RUN cd /opt; wget https://github.com/genome/bam-readcount/archive/v0.8.0.tar.gz; \
    tar xvfz v0.8.0.tar.gz; rm v0.8.0.tar.gz; \
    cd bam-readcount-0.8.0; \
    cmake .; make; \
    mv bin/bam-readcount /usr/local/bin/;

# Install Scripts
RUN mkdir -p /project/PHG/PHG_Clinical; \
    cd /project/PHG/PHG_Clinical; \
    git clone -b version_0.5.9 --single-branch https://github.com/bcantarel/genomeseer.git; \
    cd genomeseer; \
    git submodule sync --recursive; git submodule update --init --recursive; \
    cp -r process_scripts/alignment/* /usr/local/bin/; \
    cp -r process_scripts/variants/* /usr/local/bin/; \
    cp -r scripts/* /usr/local/bin/;

ENV PATH "$PATH:/usr/local/bin"

WORKDIR /data/
