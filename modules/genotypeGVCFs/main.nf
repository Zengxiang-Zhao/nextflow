process GENOTYPE_GVCFS {
    tag "${meta.id}"

    publishDir "${params.outdir}/genotype_gvcfs"

    input:
    tuple val(meta), path(gvcf), path(gvcf_tbi)

    output:
    tuple val(meta), path("${meta.id}.vcf.gz"), path("${meta.id}.vcf.gz.tbi"), emit: vcf


    script:
    """

    gatk GenotypeGVCFs  -R ${params.reference} -V ${gvcf} -O ${meta.id}.vcf.gz

    """
}