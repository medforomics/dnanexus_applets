FROM ubuntu:16.04
LABEL Author="Erika Villa" \
      Maintainer="b.cantarel@gmail.com"


#install additional requirements
RUN apt-get update; apt-get install -y build-essential checkinstall; \
    apt-get install -y libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev zlib1g-dev liblzma-dev libcurl4-gnutls-dev libncurses5-dev wget unzip git default-jre default-jdk;


# Make destination and work directory
RUN mkdir -p /opt;
RUN mkdir -p /opt/bin;
#ENV http_proxy http://proxy.swmed.edu:3128/
#ENV https_proxy http://proxy.swmed.edu:3128/


RUN cd /opt;  wget https://sourceforge.net/projects/subread/files/subread-2.0.0/subread-2.0.0-Linux-x86_64.tar.gz; \
	tar zxvf subread-2.0.0-Linux-x86_64.tar.gz
		
ENV PATH "$PATH:/opt/subread-2.0.0-Linux-x86_64/bin"

RUN cd /opt; git clone https://github.com/gpertea/stringtie; \
	cd stringtie; \
	make release;

ENV PATH "$PATH:/opt/stringtie"
