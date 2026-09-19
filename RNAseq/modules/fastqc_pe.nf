#!/usr/bin/env nextflow

/*
 * Run FastQC on paired-end reads
 */ 
process FASTQC_PE {
    tag "$meta.id"
    container "community.wave.seqera.io/library/trim-galore:0.6.10--1bf8ca4e1967cd18"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*_fastqc.zip"), emit:zip
    tuple val(meta), path("*_fastqc.html"), emit:html

    script:
    """
    fastqc ${reads}
    """
}