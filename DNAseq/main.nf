include { FASTQC } from './modules/fastqc/main.nf'
include { BWA } from './modules/bwa/main.nf'
include { MARKDUPLICATES } from './modules/markduplicates/main.nf'
include { SAMTOOLS_STATS } from './modules/samtools_stats/main.nf'
include { MOSDEPTH } from './modules/mosdepth/main.nf'
include { BASE_RECALIBRATOR } from './modules/baseRecalibrator/main.nf'
include { APPLYBQSR } from './modules/applyBQSR/main.nf'
include { SAMTOOLS_STATS as SAMTOOLS_STATS_POST_BQSR } from './modules/samtools_stats/main.nf'
include { MOSDEPTH as MOSDEPTH_POST_BQSR } from './modules/mosdepth/main.nf'
include { HAPLOTYPECALLER } from './modules/haplotypeCaller/main.nf'
include { GENOTYPE_GVCFS } from './modules/genotypeGVCFs/main.nf'
include {BCFTOOLS_FILTER} from './modules/bcftools_filter/main.nf'
include { SNPEFF } from './modules/snpEff/main.nf'

workflow {
    samplesheet = file(params.input)
    samples_ch = Channel.fromPath(samplesheet)
        .splitCsv(header: true)
        .map { row -> 
            def meta = [id:"${row.sample}-${row.lane}", sample: row.sample, lane: row.lane]
            tuple(meta, file(row.fastq_1), file(row.fastq_2)) }

    FASTQC(samples_ch)

    BWA(samples_ch)

    grouped_bam = BWA.out.sorted_bam
        .map { meta, bam -> tuple(meta.sample, bam) }
        .groupTuple(by:0)
        .map { sample_name, bam_files -> 
            def meta = [id: sample_name]
            tuple(meta, bam_files) 
        }

    MARKDUPLICATES(grouped_bam)

    SAMTOOLS_STATS(MARKDUPLICATES.out.marked_bam)

    MOSDEPTH(MARKDUPLICATES.out.marked_bam)

    BASE_RECALIBRATOR(MARKDUPLICATES.out.marked_bam)

    APPLYBQSR(BASE_RECALIBRATOR.out.recal_data_table)

    SAMTOOLS_STATS_POST_BQSR(APPLYBQSR.out.recal_bam)

    MOSDEPTH_POST_BQSR(APPLYBQSR.out.recal_bam)

    HAPLOTYPECALLER(APPLYBQSR.out.recal_bam)

    GENOTYPE_GVCFS(HAPLOTYPECALLER.out.gvcf)

    BCFTOOLS_FILTER(GENOTYPE_GVCFS.out.vcf)

    SNPEFF(BCFTOOLS_FILTER.out.filtered_vcf)

    
}