#!/usr/bin/env nextflow

/*
 * Per-sample alignment statistics
 * - samtools flagstat
 * - raw reads count from trimmed fastq
 * - aligned reads count (-F 4)
 */
process ALIGN_STATS {
    tag "$meta.id"
    container "community.wave.seqera.io/library/hisat2_samtools:5e49f68a37dc010e"

    input:
    tuple val(meta), path(bam), path(bai), path(read1), path(read2)  // sorted bam (and bai) +
            

    output:
    tuple val(meta), path("${meta.id}.flagstat.txt"), emit: flagstat
    tuple val(meta), path("${meta.id}.align_stats.tsv"), emit: stats_tsv

    script:

    def sample = meta.id

    """
    # 1. flagstat
    samtools flagstat ${bam} > ${sample}.flagstat.txt

    # 2. raw reads (R1 的行数 / 4)
    raw=\$(zcat ${read1} | wc -l)
    raw=\$((raw / 4))

    # 3. aligned reads (排除 unmapped)
    aligned=\$(samtools view -c -F 4 ${bam})

    # 4. 计算百分比
    #perc=\$(echo "scale=2; \$aligned * 100 / \$raw" | bc)
    perc=\$(awk -v aligned="\$aligned" -v raw="\$raw" \
    'BEGIN {printf "%.2f", aligned * 100 / raw}')

    # 5. 输出单行 TSV（不含表头，表头由合并进程统一加）
    printf "%s\\t%s\\t%s\\t%s\\n" "${sample}" "\$raw" "\$aligned" "\$perc" \\
        > ${sample}.align_stats.tsv
    """
}