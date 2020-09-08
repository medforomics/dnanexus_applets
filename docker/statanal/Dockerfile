FROM r-base:4.0.2
LABEL Author="Jeremy Mathews" \
      Maintainer="b.cantarel@gmail.com"

RUN apt-get update -y;
RUN mkdir -p /opt;
RUN mkdir -p /opt/bin;

#
RUN R -e "install.packages('BiocManager', dependencies=TRUE, repos='http://cran.rstudio.com/')";
    R -e "BiocManager::install('edgeR')";
    R -e "BiocManager::install('DESeq2')";
    R -e "install.packages('DESeq2', dependencies=TRUE, repos='http://cran.rstudio.com/')";
    R -e "install.packages('RColorBrewer', dependencies=TRUE, repos='http://cran.rstudio.com/')";
    R -e "install.packages('gplots', dependencies=TRUE, repos='http://cran.rstudio.com/')";
    R -e "BiocManager::install('DESeq2')";
    R -e "BiocManager::install('ballgown')";
