process BASE_RECALIBRATOR {
    tag "${meta.id}"

    publishDir "${params.outdir}/base_recalibrator"

    input:
    tuple val(meta), path(marked_bam),path(marked_bam_bai)

    output:
    tuple val(meta), path(marked_bam), path("${meta.id}_recal_data.table"), emit: recal_data_table


    script:
    """
    conda run -n ngs gatk BaseRecalibrator \
    -I ${marked_bam} \
    -R ${params.reference} \
    --known-sites ${params.known_sites} \
    -O ${meta.id}_recal_data.table
    """
}