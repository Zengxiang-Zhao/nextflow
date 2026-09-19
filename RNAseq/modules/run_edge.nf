#!/usr/bin/env nextflow

/*
 * Differential expression analysis with edgeR
 */
process RUN_EDGER {
    tag "edgeR"
    container "community.wave.seqera.io/library/bioconductor-deseq2_bioconductor-edger_r-ape:e36bbcdc30322ca0"


    input:
    path counts_txt
    path r_script

    output:
    path "edgeR_allcomp.csv", emit: edge_table

    script:
    """
    cp ${counts_txt} counts.txt
    Rscript ${r_script}
    """
}