FROM ubuntu:16.04
LABEL Author="Erika Villa" \
      Maintainer="b.cantarel@gmail.com"


#install additional requirements

RUN apt-get update; apt-get install -y build-essential checkinstall; \
		apt-get install -y libreadline-gplv2-dev cmake patch libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev zlib1g-dev liblzma-dev libcurl4-gnutls-dev libncurses5-dev wget unzip git default-jre default-jdk;

# Make destination and work directory
RUN mkdir -p /opt;
RUN mkdir -p /opt/bin;

#ENV http_proxy http://proxy.swmed.edu:3128/
#ENV https_proxy http://proxy.swmed.edu:3128/

#install samtools
RUN cd /opt; wget https://github.com/samtools/samtools/releases/download/1.10/samtools-1.10.tar.bz2; \
    tar -vxjf samtools-1.10.tar.bz2; \
		rm samtools-1.10.tar.bz2; \
    cd samtools-1.10; \
    ./configure; make; \ 
		make install; \
    cp samtools /usr/local/bin;
	
#install bam-readcount
RUN cd /opt; wget https://github.com/genome/bam-readcount/archive/v0.8.0.tar.gz; \
		tar vxzf v0.8.0.tar.gz; \ 
		rm v0.8.0.tar.gz; \
		cd bam-readcount-0.8.0; \
		cmake . ; \
		make; \
		cp bin/bam-readcount /usr/local/bin;

ENV PATH "$PATH:/usr/local/bin"

WORKDIR /data/
