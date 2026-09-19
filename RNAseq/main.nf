#!/usr/bin/env nextflow

// Module INCLUDE statement
include { FASTQC_PE } from './modules/fastqc_pe.nf'
include { TRIM_GALORE_PE } from './modules/trim_galore_pe.nf'
include { MULTIQC } from './modules/multiqc.nf'
include { HISAT2_ALIGN } from './modules/hisat2_align.nf'
include { ALIGN_STATS } from './modules/align_stats.nf'
include { COLLECT_STATS } from './modules/collect_stats.nf'
include { FEATURE_COUNTS } from './modules/feature_counts.nf'
include { SAMPLE_TREE } from './modules/sample_tree.nf'
include { RUN_EDGER } from './modules/run_edge.nf'
include { VENN } from './modules/draw_venn.nf'
include { GO_RICH } from './modules/go_rich.nf'
include { HEATMAP } from './modules/heatmap.nf'
include { DRAW_VELCANO } from './modules/draw_velcano.nf'



/*
 * pipe parameters
 */
params {
    input: Path
    hisat2_index: Path
    report_id: String
    gtf: Path
}

workflow {
    main:
    // Run FastQC on paired-end reads
    read_ch = channel.fromPath(params.input)
        .splitCsv(header:true,sep: '\t', skip: 4)
        .map{ row ->
            def meta = [
                id: row.SampleName,
                factor: row.Factor,
                sample_long: row.SampleLong,
                experiment: row.Experiment,
                date: row.Date,
            ]
            [meta, [file(row.FileName1), file(row.FileName2)]]

        }

    FASTQC_PE(read_ch)
    TRIM_GALORE_PE(read_ch)

    multiqc_files_ch = channel.empty().mix(
        FASTQC_PE.out.zip,
        FASTQC_PE.out.html,
        TRIM_GALORE_PE.out.trimming_report,
        TRIM_GALORE_PE.out.fastqc_report
    )
    
    multiqc_files_list = multiqc_files_ch.map{ meta, file -> file }.collect()

    MULTIQC( multiqc_files_list, params.report_id )

    HISAT2_ALIGN( TRIM_GALORE_PE.out.trimmed_reads, file(params.hisat2_index) )

    // For stats
    bam_ch = HISAT2_ALIGN.out.sorted_bam.map{ meta, bam, bai -> [meta.id, meta, bam, bai] }
    reads_ch = TRIM_GALORE_PE.out.trimmed_reads.map{ meta, read1, read2 -> [meta.id, meta, read1, read2] }

    joined_ch =   bam_ch.join(reads_ch, by: 0)
    
    stats_input = joined_ch.map{ id, meta, bam, bai, meta2, read1, read2 -> [meta, bam, bai, read1, read2] }
    
    ALIGN_STATS(stats_input)

    collect_stats_input = ALIGN_STATS.out.stats_tsv.map{ meta, stats_tsv -> stats_tsv }.collect()

    COLLECT_STATS(collect_stats_input)
    // End stats

    feature_counts_input = HISAT2_ALIGN.out.sorted_bam.map{ meta, sorted_bam, bai -> sorted_bam }.collect()
    println "feature_counts_input: ${feature_counts_input}"

    FEATURE_COUNTS(feature_counts_input, params.gtf)

    SAMPLE_TREE(FEATURE_COUNTS.out.gene_counts, file("${projectDir}/scripts/sample_tree.R"))

    RUN_EDGER(FEATURE_COUNTS.out.gene_counts, file("${projectDir}/scripts/run_edge.R"))

    VENN(RUN_EDGER.out.edge_table, file("${projectDir}/scripts/draw_venn.R"))

    GO_RICH(RUN_EDGER.out.edge_table, file("${projectDir}/scripts/go_rich.R"))

    HEATMAP(FEATURE_COUNTS.out.gene_counts, RUN_EDGER.out.edge_table, file("${projectDir}/scripts/draw_heatmap.R"))

    DRAW_VELCANO(RUN_EDGER.out.edge_table, file("${projectDir}/scripts/draw_volcano.R"))

    publish:
    // Publish output files
    fastqc_zip = FASTQC_PE.out.zip
    fastqc_html = FASTQC_PE.out.html
    trimmed_reads = TRIM_GALORE_PE.out.trimmed_reads
    trimming_report = TRIM_GALORE_PE.out.trimming_report
    fastqc_report = TRIM_GALORE_PE.out.fastqc_report
    multiqc_report = MULTIQC.out.report
    multiqc_data = MULTIQC.out.data

    sorted_bam = HISAT2_ALIGN.out.sorted_bam
    hisat2_log = HISAT2_ALIGN.out.log

    flagstat = ALIGN_STATS.out.flagstat
    stats_tsv = ALIGN_STATS.out.stats_tsv

    table = COLLECT_STATS.out.table

    feature_counts = FEATURE_COUNTS.out.gene_counts
    feature_counts_summary = FEATURE_COUNTS.out.gene_counts_summary

    tree_png = SAMPLE_TREE.out.tree_png

    edge_table = RUN_EDGER.out.edge_table

    venn_png = VENN.out.venn_png

    go_csv = GO_RICH.out.go_csv
    go_png = GO_RICH.out.go_png

    heatmap_png = HEATMAP.out.heatmap_png

    volcano_png = DRAW_VELCANO.out.volcano_png




}


output {
    // Output files

    fastqc_zip {
        path 'fastqc'
    }
    fastqc_html {
        path 'fastqc'
    }

    trimmed_reads {
        path 'trimming'
    }
    trimming_report {
        path 'trimming'
    }
    fastqc_report {
        path 'trimming'
    }
    multiqc_report {
        path 'multiqc'
    }
    multiqc_data {
        path 'multiqc'
    }

    sorted_bam {
        path 'alignment'
    }
    hisat2_log {
        path 'alignment'
    }

    flagstat {
        path 'stats'
    }
    stats_tsv {
        path 'stats'
    }

    table {
        path 'stats'
    }

    feature_counts {
        path 'counts'
    }
    feature_counts_summary {
        path 'counts'

    }

    tree_png {
        path 'sample_tree'
    }

    edge_table {
        path 'edgeR'
    }

    venn_png {
        path 'venn'
    }

    go_csv {
        path 'go_rich'
    }
    go_png {
        path 'go_rich' 
    }

    heatmap_png {
        path 'heatmap'
    }

    volcano_png {
        path 'volcano'
    }
}