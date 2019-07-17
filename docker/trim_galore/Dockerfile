FROM ubuntu:16.04
LABEL maintainer="b.cantarel@gmail.com"

# install additional requirements
RUN apt-get update && apt-get install -y \
   curl \
   unzip \
   python3-pip

# Install cutadapt

RUN pip3 install cutadapt==2.0

# Install trim_galore
ENV DEST_DIR /opt/
ENV http_proxy http://proxy.swmed.edu:3128/
ENV https_proxy http://proxy.swmed.edu:3128/

# Make destination directory
RUN mkdir -p /opt

WORKDIR /data

# download and extract binaries
# Do this in one command to avoid caching the zip file and its removal in separate layers
RUN curl  -fsSL https://github.com/FelixKrueger/TrimGalore/archive/0.6.3.tar.gz -o trim_galore.tar.gz
RUN tar xvzf trim_galore.tar.gz
RUN mv TrimGalore-0.6.3 /opt/trim_galore

# Link executable to /usr/local/bin
RUN ln -s /opt/trim_galore/trim_galore /usr/local/bin/trim_galore

CMD ["/usr/local/bin/trim_galore"]