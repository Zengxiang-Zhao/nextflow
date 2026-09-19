process APPLYBQSR {
    tag "${meta.id}"
    
    publishDir "${params.outdir}/applybqsr"

    input:
    tuple val(meta), path(marked_bam), path(recal_data_table)

    output:
    tuple val(meta), path("*_recal.bam"), path("*_recal.bam.bai"), emit: recal_bam

    script:
    """
    gatk ApplyBQSR -I ${marked_bam} -R ${params.reference} -bqsr ${recal_data_table} -O ${meta.id}_recal.bam

    samtools index ${meta.id}_recal.bam
    """
}