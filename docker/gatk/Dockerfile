FROM broadinstitute/gatk:4.1.4.0

LABEL Author="Jeremy Mathews" \
      Maintainer=BICF@UTSouthwestern.edu

RUN apt-get update && \
    apt-get install -y autoconf automake make gcc zlib1g-dev libbz2-dev liblzma-dev libcurl4-gnutls-dev libssl-dev libncurses5-dev git

WORKDIR /usr/bin

RUN wget https://github.com/samtools/htslib/releases/download/1.8/htslib-1.8.tar.bz2 && \
    tar -vxjf htslib-1.8.tar.bz2 && \
    rm htslib-1.8.tar.bz2

WORKDIR /usr/bin/htslib-1.8
RUN make && make install

WORKDIR /usr/bin
RUN wget https://github.com/samtools/samtools/releases/download/1.8/samtools-1.8.tar.bz2 && \
    tar -xvjf samtools-1.8.tar.bz2 && \
    rm samtools-1.8.tar.bz2

WORKDIR /usr/bin/samtools-1.8
RUN ./configure
RUN make && make install

RUN mkdir -p /usr/local/share/perl/5.22.1

RUN cd /opt; wget http://sourceforge.net/projects/vcftools/files/vcftools_0.1.13.tar.gz/download; tar xvfz download; rm download; cd vcftools_0.1.13; make; cp bin/* /usr/local/bin; cp lib/* /usr/local/lib; cp perl/* /usr/local/share/perl/5.22.1/

RUN cd /opt; wget http://sourceforge.net/projects/snpeff/files/snpEff_latest_core.zip; unzip snpEff_latest_core.zip; mv snpEff /usr/local/bin/

RUN cd /opt; wget https://github.com/broadinstitute/picard/releases/download/2.20.3/picard.jar; mv /opt/picard.jar /usr/local/bin/
RUN chmod +x /usr/local/bin/picard.jar

RUN cd /opt; git clone https://git.biohpc.swmed.edu/ngsclialab/clinseq_workflows.git; cd clinseq_workflows; \
    git submodule sync --recursive; git submodule update --init --recursive; \
    cp -r process_scripts/variants/* /usr/local/bin/;

WORKDIR /data

ENV PATH="/usr/bin/htslib-1.8/bin:/usr/bin/samtools-1.8/bin:$PATH"
