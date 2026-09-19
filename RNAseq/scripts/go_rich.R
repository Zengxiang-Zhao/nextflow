#!/usr/bin/env Rscript

suppressPackageStartupMessages({
    library(clusterProfiler)
    library(org.At.tair.db)
    library(ggplot2)
})

# ---------- 读取数据 ----------
res <- read.csv("edgeR_allcomp.csv", stringsAsFactors = FALSE)

# 从 gene 列提取纯基因名（去掉 "comparison." 前缀）
res$gene_clean <- sub("^[^.]+\\.", "", res$gene)

# ---------- 循环所有 comparison ----------
comps <- unique(res$comparison)
cat("Found comparisons:", paste(comps, collapse = ", "), "\n\n")

comps
# 汇总所有 comparison 的富集结果
all_go <- list()

for (comp in comps) {
    cat("========================================\n")
    cat("Processing:", comp, "\n")
    
    sub_res <- res[res$comparison == comp, ]
    
    # 提取显著差异基因（用 PValue，因为你的数据 FDR 都很大）
    sig_genes <- unique(
        # sub_res$gene_clean[abs(sub_res$logFC) > 1 ]
        
        sub_res$gene_clean[abs(sub_res$logFC) > 1 & sub_res$PValue < 0.05]
    )
    
    cat("  Significant genes:", length(sig_genes), "\n")
    
    # 基因太少就跳过
    if (length(sig_genes) < 10) {
        cat("  Too few genes (<10), skipping GO enrichment.\n\n")
        next
    }
    
    # ---------- GO 富集 ----------
    ego <- tryCatch(
        enrichGO(
            gene          = sig_genes,
            OrgDb         = org.At.tair.db,
            keyType       = "TAIR",
            ont           = "MF",  # 可选: "BP", "CC", "MF"
            pAdjustMethod = "BH",
            pvalueCutoff  = 0.05
        ),
        error = function(e) {
            cat("  enrichGO failed:", conditionMessage(e), "\n\n")
            return(NULL)
        }
    )
    
    if (is.null(ego) || nrow(as.data.frame(ego)) == 0) {
        cat("  No enriched terms.\n\n")
        next
    }
    
    # ---------- 输出 CSV ----------
    ego_df <- as.data.frame(ego)
    ego_df$comparison <- comp
    
    out_csv <- paste0("GO_enrichment_", comp, ".csv")
    write.csv(ego_df, out_csv, row.names = FALSE)
    cat("  Wrote:", out_csv, "(", nrow(ego_df), "terms )\n")
    
    # ---------- 画柱状图 ----------
    out_png <- paste0("GO_barplot_", comp, ".png")
    png(out_png, width = 900, height = 700)
    print(barplot(ego, showCategory = 20, title = paste0("GO BP (", comp, ")")))
    dev.off()
    cat("  Wrote:", out_png, "\n\n")
    
    # 收集结果
    all_go[[comp]] <- ego_df
}

# ---------- 合并所有结果 ----------
if (length(all_go) > 0) {
    combined <- do.call(rbind, all_go)
    write.csv(combined, "GO_enrichment_all.csv", row.names = FALSE)
    cat("Merged all comparisons into GO_enrichment_all.csv\n")
} else {
    cat("No GO enrichment results for any comparison.\n")
}
