#!/usr/bin/env Rscript

suppressPackageStartupMessages({
    library(ggplot2)
    library(dplyr)
})

# 读取 edgeR 结果
res <- read.csv("edgeR_allcomp.csv", stringsAsFactors = FALSE)
res$gene_clean <- sub("^[^.]+\\.", "", res$gene)


comps <- unique(res$comparison)
for (comp in comps) {

    plot_df <- res[res$comparison == comp, ]

    # 分类：上调 / 下调 / 不显著
    plot_df <- plot_df %>%
        mutate(
            group = case_when(
                logFC >  1 & PValue < 0.05 ~ "Up",
                logFC < -1 & PValue < 0.05 ~ "Down",
                TRUE                        ~ "NS"
            )
        )

    # 火山图
    p <- ggplot(plot_df, aes(x = logFC, y = -log10(PValue), color = group)) +
        geom_point(alpha = 0.6, size = 1.5) +
        scale_color_manual(values = c(
            "Up"   = "#E41A1C",
            "Down" = "#377EB8",
            "NS"   = "grey70"
        )) +
        geom_vline(xintercept = c(-1, 1), linetype = "dashed", color = "grey40") +
        geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "grey40") +
        labs(
            title = paste0("Volcano Plot (", comp, ")"),
            x     = "log2 Fold Change",
            y     = "-log10(PValue)",
            color = "Group"
        ) +
        theme_bw() +
        theme(
            panel.grid.minor = element_blank(),
            legend.position  = "right"
        )


    ggsave(paste0("volcano_", comp, ".png"), plot = p,
        width = 7, height = 6, dpi = 150)
}
