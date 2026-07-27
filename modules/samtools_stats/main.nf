process SAMTOOLS_STATS {
    tag "${meta.id}"

    publishDir "${params.outdir}/samtools_stats"

    input:
    tuple val(meta), path(marked_bam), path(marked_bam_bai)

    output:
    tuple val(meta), path("*.marked_bam.stats"), emit: stats

    script:
    """
    samtools stats --threads 1 ${marked_bam} > ${meta.id}.marked_bam.stats
    """
}