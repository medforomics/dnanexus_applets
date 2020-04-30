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

# Install Picard + ABRA2
RUN cd /opt/bin; wget https://github.com/broadinstitute/picard/releases/download/2.21.7/picard.jar; \
    cd /opt/bin; wget https://github.com/mozack/abra2/releases/download/v2.18/abra2-2.18.jar; \
    cp -R /opt/bin/* /usr/local/bin/; \
    chmod +x /usr/local/bin/picard.jar; \
    chmod +x /usr/local/bin/abra2-2.18.jar;
ENV PICARD "/usr/local/bin"
ENV ABRA "/usr/local/bin"

# Install Scripts
RUN mkdir -p /project/PHG/PHG_Clinical; \
    cd /project/PHG/PHG_Clinical; \
    git clone -b version_0.5.4 --single-branch https://github.com/bcantarel/genomeseer.git; \
    cd genomeseer; \
    git submodule sync --recursive; git submodule update --init --recursive; \
    cp -r process_scripts/variants/* /usr/local/bin/; \
    cp -r scripts/* /usr/local/bin/;

ENV PATH "$PATH:/usr/local/bin"

WORKDIR /data
