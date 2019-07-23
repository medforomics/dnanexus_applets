FROM ubuntu:16.04
LABEL maintainer="b.cantarel@gmail.com"

# install additional requirements
RUN apt-get update; apt-get install -y curl unzip git wget zlib1g-dev python python-pip gcc libbz2-dev libncurses5-dev libncursesw5-dev liblzma-dev default-jre default-jdk cmake r-base libboost-all-dev pkg-config parallel

# Make destination and work directory
RUN mkdir -p /opt
RUN mkdir -p /opt/bin

# Install SamTools
RUN cd /opt; wget https://github.com/samtools/htslib/releases/download/1.9/htslib-1.9.tar.bz2; tar -vxjf htslib-1.9.tar.bz2; cd htslib-1.9; make; make install
RUN cd /opt; wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2; tar -vxjf samtools-1.9.tar.bz2; cd samtools-1.9; make; make install
RUN cd /opt; wget https://github.com/samtools/bcftools/releases/download/1.9/bcftools-1.9.tar.bz2; tar -vxjf bcftools-1.9.tar.bz2; cd bcftools-1.9; make; make install

#Bedtools
RUN cd /opt; wget https://github.com/arq5x/bedtools2/releases/download/v2.28.0/bedtools-2.28.0.tar.gz; tar xvfz bedtools-2.28.0.tar.gz; cd bedtools2; make; cp bin/* /opt/bin

# Install FGBio and Picard
RUN cd /opt/bin; wget https://github.com/broadinstitute/picard/releases/download/2.20.3/picard.jar
RUN cp -R /opt/bin/* /usr/local/bin/

# Install SNPEff and Human Genome
RUN cd /opt/bin; wget http://sourceforge.net/projects/snpeff/files/snpEff_v4_3t_core.zip; unzip snpEff_v4_3t_core.zip; cd snpEff; java -jar snpEff.jar download GRCh38.86

RUN cd /opt; wget https://github.com/vcftools/vcftools/releases/download/v0.1.16/vcftools-0.1.16.tar.gz; tar xvfz vcftools-0.1.16.tar.gz; cd vcftools-0.1.16; ./configure; make; make install

# FASTQC
ENV DST=/opt
ENV URL=http://www.bioinformatics.babraham.ac.uk/projects/fastqc/
ENV ZIP=fastqc_v0.11.8.zip

RUN wget $URL/$ZIP -O $DST/$ZIP; unzip - $DST/$ZIP -d $DST; rm $DST/$ZIP; cd $DST/FastQC; chmod 755 fastqc; cp $DST/FastQC/fastqc /usr/local/bin/fastqc

WORKDIR /data/

CMD ["/usr/local/bin/samtools"]