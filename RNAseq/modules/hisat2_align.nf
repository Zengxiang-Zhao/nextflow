#!/usr/bin/env nextflow

/*
 * Align reads to a reference genome
 */
process HISAT2_ALIGN {
    tag "$meta.id"

    container "community.wave.seqera.io/library/hisat2_samtools:5e49f68a37dc010e"

    stageInMode 'copy' 

    input:
    tuple val(meta), path(read1), path(read2)
    path index_zip

    output:
    tuple val(meta), path("${meta.id}.sorted.bam"), path("${meta.id}.sorted.bam.bai"), emit: sorted_bam
    tuple val(meta), path("${meta.id}.hisat2.log"), emit: log

    script:
    """
    tar -xzvf ${index_zip}
    hisat2 -x ${index_zip.simpleName} -1 ${read1} -2 ${read2} \
        --new-summary --summary-file ${meta.id}.hisat2.log | \
        samtools view -bS -o ${meta.id}.bam

    samtools sort -o ${meta.id}.sorted.bam ${meta.id}.bam
    samtools index ${meta.id}.sorted.bam
    rm ${meta.id}.bam
    """
}