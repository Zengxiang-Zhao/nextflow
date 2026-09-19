process MARKDUPLICATES {
    tag "${meta.id}"

    publishDir "${params.outdir}/markduplicates"

    input:
    tuple val(meta), path(sorted_bam)

    output:
    tuple val(meta), path("*_marked.bam"), path("*_marked.bam.bai"), emit: marked_bam
    path "*_metrics.txt"

    script:

    def input_bam = sorted_bam.collect {bam_file -> "--INPUT ${bam_file}"}.join(" ")
    println("Input BAM files: ${input_bam}")
    """
    gatk MarkDuplicates ${input_bam} -O ${meta.id}_marked.bam -M ${meta.id}_metrics.txt
    
    samtools index ${meta.id}_marked.bam
    """
}