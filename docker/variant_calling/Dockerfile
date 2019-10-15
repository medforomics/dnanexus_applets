FROM ubuntu:16.04
LABEL maintainer="b.cantarel@gmail.com"

# install additional requirements
RUN apt-get update; apt-get install -y curl unzip git wget zlib1g-dev python python-pip gcc libbz2-dev libncurses5-dev libncursesw5-dev liblzma-dev default-jre default-jdk cmake r-base libboost-all-dev bzip2 g++ make

# Make destination and work directory
RUN mkdir -p /opt
RUN mkdir -p /opt/bin

# Install SamTools
RUN cd /opt; wget https://github.com/samtools/htslib/releases/download/1.9/htslib-1.9.tar.bz2; tar -vxjf htslib-1.9.tar.bz2; cd htslib-1.9; make; make install
RUN cd /opt; wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2; tar -vxjf samtools-1.9.tar.bz2; cd samtools-1.9; make; make install
RUN cd /opt; wget https://github.com/samtools/bcftools/releases/download/1.9/bcftools-1.9.tar.bz2; tar -vxjf bcftools-1.9.tar.bz2; cd bcftools-1.9; make; make install

RUN cd /opt; git clone --recursive --branch v1.3.1 git://github.com/ekg/freebayes.git; cd freebayes; make; make install

RUN pip install cython
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:/usr/local/htslib/include
ENV LIBRARY_PATH $LIBRARY_PATH:/usr/local/htslib/lib
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/htslib/lib
RUN cd /opt; git clone https://github.com/andyrimmer/Platypus.git; cd Platypus; make; mv ../Platypus /usr/local/bin 

RUN cd /opt; wget https://cfhcable.dl.sourceforge.net/project/virmid/Virmid-1.2.0.tar.gz; tar xvfz Virmid-1.2.0.tar.gz; mv Virmid1.2 /usr/local/bin/virmid

RUN cd /opt; wget https://github.com/dkoboldt/varscan/releases/download/2.4.2/VarScan.v2.4.2.jar; mv VarScan.v2.4.2.jar /usr/local/bin

#Install R and statmod
RUN R -e "install.packages('statmod', repos = 'http://cran.us.r-project.org')"

RUN apt-get install -y cpanminus
RUN cpanm CPAN::Meta Module::Build

RUN cd /opt; wget https://github.com/nhansen/Shimmer/archive/v0.2.tar.gz; tar xvfz v0.2.tar.gz; cd Shimmer-0.2; perl Build.PL; ./Build; ./Build test; ./Build install

RUN cd /opt; git clone https://github.com/genome/pindel.git; cd pindel/; ./INSTALL /opt/htslib-1.9; mv /opt/pindel /usr/local/bin

RUN cd /opt; wget https://github.com/Illumina/strelka/releases/download/v2.9.10/strelka-2.9.10.centos6_x86_64.tar.bz2; tar xf strelka-2.9.10.centos6_x86_64.tar.bz2; rm -f strelka-2.9.10.centos6_x86_64.tar.bz2; mv strelka-2.9.10.centos6_x86_64 /usr/local/bin;

ENV PATH=/usr/local/bin/strelka-2.9.10.centos6_x86_64/bin:${PATH}

RUN cd /opt; wget https://github.com/Illumina/manta/releases/download/v1.6.0/manta-1.6.0.release_src.tar.bz2; tar -xjf manta-1.6.0.release_src.tar.bz2; cd /usr/local/bin; /opt/manta-1.6.0.release_src/configure --jobs=4; make -j4 install;

WORKDIR /data/

CMD ["/usr/local/bin/samtools"]
