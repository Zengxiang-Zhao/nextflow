#!/usr/bin/env nextflow

/*
 * Draw Venn diagram of up/down regulated genes
 */
process DRAW_VELCANO {
    tag "volcano"
    container "my-r-env:devel"

    input:
    path edgeR_csv
    path r_script

    output:
    path "volcano*.png", emit: volcano_png

    script:
    """
    # cp ${edgeR_csv} edgeR_allcomp.csv
    Rscript ${r_script}
    """
}