FROM r-base:4.0.2
LABEL Author="Jeremy Mathews" \
      Maintainer="b.cantarel@gmail.com"

RUN apt-get update -y; apt-get install -y git;
RUN mkdir -p /opt;
RUN mkdir -p /opt/bin;

#
RUN R -e "install.packages('BiocManager', dependencies=TRUE, repos='http://cran.rstudio.com/')"; \
    R -e "BiocManager::install('edgeR')"; \
    R -e "BiocManager::install('DESeq2')"; \
    R -e "install.packages('DESeq2', dependencies=TRUE, repos='http://cran.rstudio.com/')"; \
    R -e "install.packages('RColorBrewer', dependencies=TRUE, repos='http://cran.rstudio.com/')"; \
    R -e "install.packages('gplots', dependencies=TRUE, repos='http://cran.rstudio.com/')"; \
    R -e "BiocManager::install('DESeq2')"; \
    R -e "BiocManager::install('ballgown')";

# Install Scripts
ENV repodir /seqprg
RUN mkdir -p /seqprg; \
    cd /seqprg; \
    git clone -b version_1.0.6 --single-branch --recursive https://github.com/bcantarel/process_scripts.git; \
    cd process_scripts; \
    cp -r genect_rnaseq/* /usr/local/bin/;

ENV isdocker 1
ENV PATH "$PATH:/usr/local/bin"

WORKDIR /data/
