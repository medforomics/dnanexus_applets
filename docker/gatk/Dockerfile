FROM broadinstitute/gatk:4.1.2.0

LABEL Author="Jeremy Mathews" \
      Maintainer=BICF@UTSouthwestern.edu

RUN apt-get update && \
    apt-get install -y autoconf automake make gcc zlib1g-dev libbz2-dev liblzma-dev libcurl4-gnutls-dev libssl-dev libncurses5-dev

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

WORKDIR /data

ENV PATH="/usr/bin/htslib-1.8/bin:/usr/bin/samtools-1.8/bin:$PATH"
