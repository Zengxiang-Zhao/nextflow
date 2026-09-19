#!/usr/bin/env nextflow

/*
 * Trim adapters and run post-trimming QC
 */
process FEATURE_COUNTS {
    tag 'all_samples'

    container "community.wave.seqera.io/library/subread:2.1.1--ab75f84c2fa06990"

    // publishDir "/mnt/truenas_share/Projects/learnNGS/rnaseqworkflow_exampledata/data/counts", mode: 'copy'

    input:
    path bam_files
    path gtf

    output:
    path "countDFeByg.txt", emit: gene_counts
    path "countDFeByg.txt.summary", emit: gene_counts_summary

    script:
    def bam_list = bam_files.collect { it.name }.join(' ')
    """
    featureCounts \
        -T 8 \
        -p --countReadPairs \
        -t exon \
        -g gene_id \
        -a ${gtf} \
        -o countDFeByg.txt \
        ${bam_list}
    """
}