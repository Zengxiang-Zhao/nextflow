#!/usr/bin/env Rscript

suppressPackageStartupMessages({
    library(DESeq2)
    library(ape)
})

# 读取 featureCounts 输出，跳过第一行注释
counts <- read.delim(
    "counts.txt",
    row.names = 1,
    skip = 1,
    comment.char = "#",
    check.names = FALSE
)

# 去掉前 5 列（Chr, Start, End, Strand, Length），保留样本列
counts <- counts[, 6:ncol(counts)]

# 从列名里去掉 .sorted.bam 后缀，得到样本名
colnames(counts) <- sub("_1_val_1\\.sorted\\.bam$", "", colnames(counts))

# 动态生成 coldata：每个样本的 condition 就是它的列名
coldata <- data.frame(
    condition = factor(colnames(counts)),
    row.names = colnames(counts)
)

# 构建 DESeqDataSet，做 rlog 转换，算 Spearman 相关
dds <- DESeqDataSetFromMatrix(counts, coldata, ~condition)
d   <- cor(assay(rlog(dds)), method = "spearman")

# 层次聚类
hc <- hclust(dist(1 - d))

# 画样本树
png("sample_tree.png", width = 800, height = 600)
plot(as.phylo(hc), type = "p", edge.col = "blue")
dev.off()
