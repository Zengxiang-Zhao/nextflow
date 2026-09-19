#!/usr/bin/env Rscript

suppressPackageStartupMessages({
    library(DESeq2)
    library(pheatmap)
})

# ---------- 读取 counts ----------
counts <- read.delim(
    "counts.txt",
    row.names = 1,
    skip = 1,
    comment.char = "#",
    check.names = FALSE
)

# 去掉前 6 列（Geneid, Chr, Start, End, Strand, Length），保留样本列
counts <- counts[, 6:ncol(counts)]

# 去掉 .sorted.bam 后缀
colnames(counts) <- sub("\\.sorted\\.bam$", "", colnames(counts))

# ---------- 构建 coldata ----------
coldata <- data.frame(
    condition = factor(sub("[AB]$", "", colnames(counts))),
    row.names = colnames(counts)
)

cat("Samples:", paste(colnames(counts), collapse = ", "), "\n")
cat("Groups: ", paste(levels(coldata$condition), collapse = ", "), "\n\n")


# ---------- DESeq2 rlog 转换（只做一次） ----------
dds <- DESeqDataSetFromMatrix(counts, coldata, ~condition)
rlog_mat <- assay(rlog(dds))


# ---------- 读取 edgeR 结果 ----------
res <- read.csv("edgeR_allcomp.csv", stringsAsFactors = FALSE)
res$gene_clean <- sub("^[^.]+\\.", "", res$gene)

comps <- unique(res$comparison)
cat("Found comparisons:", paste(comps, collapse = ", "), "\n\n")

# ---------- 循环所有 comparison ----------
for (comp in comps) {
    cat("========================================\n")
    cat("Processing:", comp, "\n")
    
    sub_res <- res[res$comparison == comp, ]
    
    # 提取显著差异基因（用 PValue，因为你的数据 FDR 都很大）
    sig <- unique(
        # sub_res$gene_clean[abs(sub_res$logFC) > 1]
        sub_res$gene_clean[abs(sub_res$logFC) > 1 & sub_res$PValue < 0.05]
    )
    
    cat("  Significant genes:", length(sig), "\n")
    
    # 只保留 counts 和 sig 的交集，避免下标越界
    sig_in_counts <- intersect(sig, rownames(rlog_mat))
    cat("  Present in counts:", length(sig_in_counts), "\n")
    
    # 基因太少就跳过
    if (length(sig_in_counts) < 2) {
        cat("  Too few genes (<2), skipping heatmap.\n\n")
        next
    }
    
    # ---------- 取 sig 基因的表达矩阵 ----------
    y <- rlog_mat[sig_in_counts, ]
    
    # ---------- 画热图 ----------
    out_png <- paste0("heatmap_", comp, ".png")
    pheatmap(
        y,
        scale = "row",
        clustering_distance_rows = "correlation",
        clustering_distance_cols = "correlation",
        main = paste0("Heatmap (", comp, ")"),
        filename = out_png,
        width = 9,
        height = 9
    )
    cat("  Wrote:", out_png, "\n\n")
}

cat("All comparisons done.\n")
