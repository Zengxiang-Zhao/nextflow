#!/usr/bin/env nextflow

/*
 * Merge per-sample stats into one table
 */
process COLLECT_STATS {
    tag "all_samples"
    container "community.wave.seqera.io/library/hisat2_samtools:5e49f68a37dc010e"

    input:
    path stats_tsv       // collect() 后的所有 TSV

    output:
    path "alignment_stats.tsv", emit: table

    script:
    """
    {
        printf "Sample\\tRawReads\\tAlignedReads\\tPerc_Aligned\\n"
        cat ${stats_tsv}
    } > alignment_stats.tsv
    """
}