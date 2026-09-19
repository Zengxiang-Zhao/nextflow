#!/usr/bin/env Rscript

suppressPackageStartupMessages({
    library(edgeR)
})

# 读取 featureCounts 输出
counts <- read.delim(
    "counts.txt",
    row.names = 1,
    skip = 1,
    comment.char = "#",
    check.names = FALSE
)

# 去掉前 5 列（Geneid, Chr, Start, End, Strand, Length）
counts <- counts[, 6:ncol(counts)]

# 去掉 .sorted.bam 后缀
colnames(counts) <- sub("\\.sorted\\.bam$", "", colnames(counts))

# 分组：去掉末尾的 A/B，得到 M1、A1、V1 等
group <- factor(sub("[AB]$", "", colnames(counts)))

# 构建 DGEList 并标准化
y <- DGEList(counts = counts, group = group)
y <- calcNormFactors(y)

# 设计矩阵
design <- model.matrix(~ 0 + group)   # 无截距，便于做所有两两比较
colnames(design) <- levels(group)

# 估计离散度并拟合
y <- estimateDisp(y, design)
fit <- glmFit(y, design)

# 做所有两两比较
all_results <- list()
for (i in 1:(nlevels(group) - 1)) {
    for (j in (i + 1):nlevels(group)) {
        g1 <- levels(group)[i]
        g2 <- levels(group)[j]
        contrast_str <- paste0(g2, " - ", g1)
        contrast <- makeContrasts(contrasts = contrast_str, levels = design)
        lrt <- glmLRT(fit, contrast = contrast)
        res <- topTags(lrt, n = Inf)$table
        res$comparison <- paste0(g2, "_vs_", g1)
        all_results[[paste0(g2, "_vs_", g1)]] <- res
    }
}

# 合并所有比较结果
final <- do.call(rbind, all_results)
final$gene <- rownames(final)

# 输出
write.csv(final, "edgeR_allcomp.csv", row.names = FALSE)
