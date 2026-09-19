#!/usr/bin/env nextflow

/*
 * Draw Venn diagram of up/down regulated genes
 */
process HEATMAP {
    tag "heatmap"
    container "my-r-env:devel"  // 替换成你生成的镜像

    input:
    path counts_txt
    path edgeR_csv
    path r_script

    output:
    path "heatmap_*.png", emit: heatmap_png, optional: true


    script:
    """
    # cp ${edgeR_csv} edgeR_allcomp.csv
    cp ${counts_txt} counts.txt
    Rscript ${r_script}
    """
}