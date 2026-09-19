FROM bioconductor/bioconductor_docker:devel

# 安装 Bioconductor 包：clusterProfiler, org.At.tair.db, DESeq2
RUN R -e "BiocManager::install(c('clusterProfiler', 'org.At.tair.db', 'DESeq2'), ask=FALSE)"

# 安装 CRAN 包：ggplot2, pheatmap
RUN R -e "install.packages(c('ggplot2', 'pheatmap'), repos='https://cloud.r-project.org/')"