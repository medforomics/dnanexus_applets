FROM ubuntu:16.04
LABEL maintainer="b.cantarel@gmail.com"

# install additional requirements
RUN apt-get update; apt-get install -y curl unzip git wget zlib1g-dev python python-pip gcc libbz2-dev libncurses5-dev libncursesw5-dev liblzma-dev default-jre default-jdk r-base 

# Make destination and work directory
RUN mkdir -p /opt
RUN mkdir -p /opt/bin
#ENV http_proxy http://proxy.swmed.edu:3128/
#ENV https_proxy http://proxy.swmed.edu:3128/

# Install BWA
RUN curl -fsSL https://github.com/lh3/bwa/archive/v0.7.17.tar.gz -o bwa.tar.gz
RUN tar xvfz bwa.tar.gz; cd bwa-0.7.17; make; cp bwa /opt/bin
RUN cd ..
RUN rm bwa.tar.gz

RUN pip install pysam

# Install BWAKit 0.7.15
RUN wget -O- http://sourceforge.net/projects/bio-bwa/files/bwakit/bwakit-0.7.12_x64-linux.tar.bz2/download |bunzip2 |tar xf -
RUN mv bwa.kit /opt/bin

# Install SamTools
RUN cd /opt; wget https://github.com/samtools/htslib/releases/download/1.9/htslib-1.9.tar.bz2; tar -vxjf htslib-1.9.tar.bz2; cd htslib-1.9; make; cp tabix bgzip /opt/bin
RUN cd /opt; wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2; tar -vxjf samtools-1.9.tar.bz2; cd samtools-1.9; make; cp samtools /opt/bin
RUN cd /opt; wget https://github.com/samtools/bcftools/releases/download/1.9/bcftools-1.9.tar.bz2; tar -vxjf bcftools-1.9.tar.bz2; cd bcftools-1.9; make; cp bcftools /opt/bin


#Bedtools
RUN cd /opt; wget https://github.com/arq5x/bedtools2/releases/download/v2.28.0/bedtools-2.28.0.tar.gz; tar xvfz bedtools-2.28.0.tar.gz; cd bedtools2; make; cp bin/* /opt/bin

# Install FGBio and Picard
RUN cd /opt/bin; wget https://github.com/fulcrumgenomics/fgbio/releases/download/0.8.1/fgbio-0.8.1.jar
RUN cd /opt/bin; wget https://github.com/broadinstitute/picard/releases/download/2.20.3/picard.jar
RUN cp -R /opt/bin/* /usr/local/bin/
RUN chmod +x /usr/local/bin/picard.jar

RUN cd /opt; wget http://sourceforge.net/projects/snpeff/files/snpEff_latest_core.zip; unzip snpEff_latest_core.zip; mv snpEff /usr/local/bin/

RUN cd /usr/local/bin; wget https://git.biohpc.swmed.edu/BICF/Astrocyte/process_scripts/raw/cabc31902db3374b96a90e98a9044a135b5329eb/variants/unionvcf.pl?inline=false; mv unionvcf.pl?inline=false unionvcf.pl;

RUN cd /usr/local/bin; wget https://git.biohpc.swmed.edu/BICF/Astrocyte/process_scripts/raw/cabc31902db3374b96a90e98a9044a135b5329eb/variants/vcfsorter.pl?inline=false; mv vcfsorter.pl?inline=false vcfsorter.pl;

RUN cd /usr/local/bin; wget https://git.biohpc.swmed.edu/ngsclialab/clinseq_workflows/raw/DNANexusCompat/scripts/sequenceqc_alignment_withumi.pl?inline=false; mv sequenceqc_alignment_withumi.pl?inline=false sequenceqc_alignment_withumi.pl;

WORKDIR /data/

CMD ["/usr/local/bin/bwa"]
