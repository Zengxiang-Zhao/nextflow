process SNPEFF {
    tag "${meta.id}"

    publishDir "${params.outdir}/snpeff"

    input:
    tuple val(meta), path(filtered_vcf)
    output:
    tuple val(meta), path("${meta.id}.annotated.vcf"), emit: annotated_vcf
    path "*.html", emit: html
    path "*.txt", emit: txt

    script:
    """
    snpEff -Xmx4g -v GRCh37.75 ${filtered_vcf} > ${meta.id}.annotated.vcf
    """

}