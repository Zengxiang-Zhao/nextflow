process FASTQC {
    tag "${meta.id}"

    publishDir "${params.outdir}/fastqc"

    input:
    tuple val(meta), path(read1), path(read2)

    output:
    path "*_fastqc.zip"
    path "*_fastqc.html"

    script:
    """
    conda run -n ngs fastqc -o . ${read1} ${read2}
    """
}