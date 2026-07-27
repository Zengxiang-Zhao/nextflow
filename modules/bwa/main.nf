process BWA {
    tag "${meta.id}"

    publishDir "${params.outdir}/bwa"

    input:
    tuple val(meta), path(read1), path(read2)

    output:
    tuple val(meta), path("*_bwa.sorted.bam"), emit: sorted_bam
    path "*_bwa.sorted.bam.bai"

    script:
    """
    bwa mem -t 4 \
    -R  '@RG\\tID:rg_1\\tSM:sample_tumor\\tPL:ILLUMINA' \
    ${params.reference_bwa} ${read1} ${read2} | samtools sort -@ 4 -o ${meta.id}_bwa.sorted.bam - 

    samtools index ${meta.id}_bwa.sorted.bam
    """
}