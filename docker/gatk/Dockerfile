FROM broadinstitute/gatk:4.1.4.0
LABEL Author="Jeremy Mathews" \
      Maintainer="b.cantarel@gmail.com"

# Install additional requirements
RUN apt-get update; apt-get install -y build-essential checkinstall; \
    apt-get install -y libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev zlib1g-dev liblzma-dev libcurl4-gnutls-dev libncurses5-dev wget unzip git default-jre default-jdk;

# Make destination and work directory
RUN mkdir -p /opt;
RUN mkdir -p /opt/bin;
#ENV http_proxy http://proxy.swmed.edu:3128/
#ENV https_proxy http://proxy.swmed.edu:3128/

# Install SamTools
RUN cd /opt; wget https://github.com/samtools/samtools/releases/download/1.10/samtools-1.10.tar.bz2; \
    tar -vxjf samtools-1.10.tar.bz2; rm samtools-1.10.tar.bz2; \
    cd samtools-1.10; \
    ./configure; make; make install; \
    cp samtools /opt/bin;

# Install Scripts
RUN mkdir -p /seqprg; \
    cd /seqprg; \
    git clone -b version_0.5.26 --single-branch --recursive https://github.com/bcantarel/genomeseer.git; \
    cd genomeseer; \
    cp -r process_scripts/variants/* /usr/local/bin/; \
    cp -r scripts/* /usr/local/bin/;

ENV gitv "version_0.5.26"

ENV PATH "$PATH:/usr/local/bin"

WORKDIR /data/
