#!/usr/bin/env Rscript

suppressPackageStartupMessages({
    library(VennDiagram)
    library(grid)
})

# 读取 edgeR 结果
res <- read.csv("edgeR_allcomp.csv", stringsAsFactors = FALSE)

# 从 gene 列提取纯基因名（去掉 "comparison." 前缀）
res$gene_clean <- sub("^[^.]+\\.", "", res$gene)

# 取第一个 comparison 来画 Venn（你也可以改成循环画所有 comparison）
comps <- unique(res$comparison)

for (comp in comps) {
    sub_res <- res[res$comparison == comp, ]

    up   <- unique(sub_res$gene_clean[sub_res$logFC >  1 & sub_res$FDR < 0.05])
    down <- unique(sub_res$gene_clean[sub_res$logFC < -1 & sub_res$FDR < 0.05])

    outfile <- paste0("venn_", comp, ".png")

    if (length(up) == 0 || length(down) == 0) {
        cat("Skipping", comp, ": empty gene list\n")
        png(outfile, width = 800, height = 600)
        plot.new()
        text(0.5, 0.5,
            paste0("No DE genes for ", comp, "\n(Up: ", length(up),
                    ", Down: ", length(down), ")"),
            cex = 1.5)
        dev.off()
        next
    }


    venn.plot <- venn.diagram(
        x = list(Up = up, Down = down),
        filename = outfile,
        fill = c("red", "blue"),
        alpha = 0.5,
        main = paste0("Up vs Down (", comp, ")")
    )
    # grid.draw(venn.plot) the object has been save to outputfile
}