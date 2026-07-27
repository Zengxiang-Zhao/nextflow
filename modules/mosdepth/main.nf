process MOSDEPTH {
    tag "${meta.id}"

    publishDir "${params.outdir}/mosdepth"

    input:
    tuple val(meta), path(marked_bam), path(marked_bam_bai)

    output:
    tuple val(meta), path("*.mosdepth.*"), emit: mosdepth

    script:
    """
    mosdepth --by 500 --threads 4 ${marked_bam} -n --fast-mode ${marked_bam}
    """
}