#!/usr/bin/env nextflow

/*
 * Draw Venn diagram of up/down regulated genes
 */
process VENN {
    tag "venn"
    container "community.wave.seqera.io/library/r-venndiagram:1.8.2--bc622d351533d808"  // 替换成你生成的镜像

    input:
    path edgeR_csv
    path r_script

    output:
    path "venn*.png", emit: venn_png

    script:
    """
    # cp ${edgeR_csv} edgeR_allcomp.csv
    Rscript ${r_script}
    """
}