#!/usr/bin/env nextflow

/*
 * Trim adapters and run post-trimming QC
 */
process TRIM_GALORE_PE {
    tag "$meta.id"
    container "community.wave.seqera.io/library/trim-galore:0.6.10--1bf8ca4e1967cd18"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*_val_1.fq.gz"), path("*_val_2.fq.gz"), emit: trimmed_reads
    tuple val(meta), path("*_trimming_report.txt"), emit: trimming_report
    tuple val(meta), path("*fastqc.{zip,html}"), emit: fastqc_report
    

    script:
    """
    trim_galore --fastqc --paired ${reads}
    """
}