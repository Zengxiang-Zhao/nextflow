#!/usr/bin/env nextflow

/*
 * Trim adapters and run post-trimming QC
 */
process SAMPLE_TREE {
    tag 'all_samples'

    container "community.wave.seqera.io/library/bioconductor-deseq2_bioconductor-edger_r-ape:e36bbcdc30322ca0"

    input:
        path counts_txt        // featureCounts 的 counts.txt
        path r_script

    output:
        path "sample_tree.png", emit: tree_png

    script:
    """
    # 把输入重命名为脚本里写死的名字
    cp ${counts_txt} counts.txt

    # 运行 R 脚本
    Rscript ${r_script}
    """
}