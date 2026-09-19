process HAPLOTYPECALLER {
    tag "${meta.id}"

    publishDir "${params.outdir}/haplotypecaller"

    input:
    tuple val(meta), path(recal_bam), path(recal_bai)

    output:
    tuple val(meta), path("${meta.id}.g.vcf.gz"), path("${meta.id}.g.vcf.gz.tbi"), emit: gvcf

    script:
    """
    echo "Running HaplotypeCaller for sample: ${meta.id}"
    
    gatk HaplotypeCaller -R ${params.reference} -I ${recal_bam} -O ${meta.id}.g.vcf.gz -ERC GVCF

    """
}