FROM trinityctat/starfusion:1.9.0
LABEL Author="Jeremy Mathews" \
      Maintainer="b.cantarel@gmail.com"

RUN apt-get update -y; apt-get install -y pigz
RUN mkdir -p /opt;
RUN mkdir -p /opt/bin;

RUN cd /opt; wget https://github.com/arq5x/bedtools2/releases/download/v2.29.2/bedtools-2.29.2.tar.gz; \
    tar xvfz bedtools-2.29.2.tar.gz; rm bedtools-2.29.2.tar.gz; \
    cd bedtools2; \
    make; \
    cp -r bin/* /usr/local/bin;

ENV PYENSEMBL_CACHE_DIR=/opt

RUN  pip install matplotlib==2.2.5; pip install pandas==0.24.2; pip install biopython==1.76; pip install future; pip install pyensembl; \
    pyensembl install --species homo_sapiens --release 95; \
    pip install agfusion; \
    agfusion download -g hg38;

RUN mkdir -p /seqprg; \
    cd /seqprg; \
    git clone -b version_1.0.0 --single-branch --recursive https://github.com/bcantarel/school.git; \
    cd school; \
    git submodule sync --recursive; git submodule update --init --recursive; \
    cp -r process_scripts/alignment/* /usr/local/bin/;

ENV isdocker 1
ENV PATH "$PATH:$STAR_FUSION_HOME:/usr/local/bin"

WORKDIR /data/
#agfusion annotate -db agfusion.homo_sapiens.95.db -g5 SLC34A2 -j5 25664330 -g3 ROS1 -j3 117329446 -o SLC34A2_25664330_ROS1_117329446