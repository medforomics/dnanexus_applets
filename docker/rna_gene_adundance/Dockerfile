FROM ubuntu:16.04
LABEL Author="Jeremy Mathews" \
      Maintainer="b.cantarel@gmail.com"


#install additional requirements
RUN apt-get update; apt-get install -y build-essential checkinstall; \
    apt-get install -y libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev zlib1g-dev liblzma-dev libcurl4-gnutls-dev libncurses5-dev wget unzip git default-jre default-jdk pigz;

# Make destination and work directory
RUN mkdir -p /opt;
RUN mkdir -p /opt/bin;
#ENV http_proxy http://proxy.swmed.edu:3128/
#ENV https_proxy http://proxy.swmed.edu:3128/

# Install Subread
RUN cd /opt; wget https://sourceforge.net/projects/subread/files/subread-2.0.0/subread-2.0.0-Linux-x86_64.tar.gz; \
    tar zxvf subread-2.0.0-Linux-x86_64.tar.gz; rm subread-2.0.0-Linux-x86_64.tar.gz; \
    cd subread-2.0.0-Linux-x86_64/bin; \
    cp -r * /usr/local/bin;

# Install StringTie
RUN cd /opt; wget http://ccb.jhu.edu/software/stringtie/dl/stringtie-2.1.1.Linux_x86_64.tar.gz; \
    tar xvfz stringtie-2.1.1.Linux_x86_64.tar.gz; rm stringtie-2.1.1.Linux_x86_64.tar.gz; \
    cd stringtie-2.1.1.Linux_x86_64; \
    cp * /usr/local/bin;

# Install Scripts
RUN mkdir -p /seqprg; \
    cd /seqprg; \
    git clone -b version_1.0.0 --single-branch --recursive https://github.com/bcantarel/school.git; \
    cd school; \
    git submodule sync --recursive; git submodule update --init --recursive; \
    cp -r process_scripts/genect_rnaseq/* /usr/local/bin/;

ENV isdocker 1
ENV PATH "$PATH:/usr/local/bin"
ENTRYPOINT ["bash","/seqprg/school/process_scripts/genect_rnaseq/geneabundance.sh"]
WORKDIR /data/
