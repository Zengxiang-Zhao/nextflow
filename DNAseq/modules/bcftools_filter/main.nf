process BCFTOOLS_FILTER {
    tag "${meta.id}"
    
    publishDir "${params.outdir}/bcftools_filter"

    input:
    tuple val(meta), path(vcf), path(vcf_tbi)

    output:
    tuple val(meta), path("${meta.id}.filtered.vcf.gz"), emit: filtered_vcf

    script:
    """
    bcftools filter -i 'GQ>20 && INFO/DP<10' ${vcf} -Oz -o ${meta.id}.filtered.vcf.gz
    """

}