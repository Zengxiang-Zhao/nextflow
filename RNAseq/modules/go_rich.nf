#!/usr/bin/env nextflow

/*
 * Draw Venn diagram of up/down regulated genes
 */
process GO_RICH {
    tag "go_rich"
    container "my-r-env:devel"  // 替换成你生成的镜像

    input:
    path edgeR_csv
    path r_script

    output:
    path "GO_enrichment_*.csv", emit: go_csv, optional: true
    path "GO_barplot_*.png", emit: go_png, optional: true

    script:
    """
    # cp ${edgeR_csv} edgeR_allcomp.csv
    Rscript ${r_script}
    """
}