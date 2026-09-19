
# Nextflow Germline Variant Calling Pipeline

A Nextflow (DSL2) pipeline for whole-genome/whole-exome germline variant calling, from raw
FASTQ reads through to annotated VCF. The workflow performs read QC, alignment, duplicate
marking, base quality score recalibration (BQSR), coverage statistics, variant calling with
GATK HaplotypeCaller, joint genotyping, filtering, and functional annotation with SnpEff.

## Pipeline Overview

```txt
FASTQ
  │
  ├── FastQC ──────────────────────────────► QC reports
  │
  └── BWA ──► sorted BAM
                │
                └── MarkDuplicates ──► marked BAM
                        │
                        ├── Samtools stats
                        ├── Mosdepth
                        │
                        └── BaseRecalibrator ──► ApplyBQSR ──► recalibrated BAM
                                                      │
                                                      ├── Samtools stats (post-BQSR)
                                                      ├── Mosdepth (post-BQSR)
                                                      │
                                                      └── HaplotypeCaller ──► GVCF
                                                              │
                                                              └── GenotypeGVCFs ──► VCF
                                                                      │
                                                                      └── bcftools filter ──► filtered VCF
                                                                              │
                                                                              └── SnpEff ──► annotated VCF
```

## Processes

| Step | Tool / Process | Description |
|------|----------------|-------------|
| 1 | `FASTQC` | Raw read quality control |
| 2 | `BWA` | Read alignment and sorting |
| 3 | `MARKDUPLICATES` | PCR duplicate marking (per sample) |
| 4 | `SAMTOOLS_STATS` | Alignment statistics on marked BAM |
| 5 | `MOSDEPTH` | Coverage statistics on marked BAM |
| 6 | `BASE_RECALIBRATOR` | Generate BQSR recalibration table |
| 7 | `APPLYBQSR` | Apply BQSR to produce recalibrated BAM |
| 8 | `SAMTOOLS_STATS_POST_BQSR` | Alignment statistics on recalibrated BAM |
| 9 | `MOSDEPTH_POST_BQSR` | Coverage statistics on recalibrated BAM |
| 10 | `HAPLOTYPECALLER` | Per-sample GVCF generation |
| 11 | `GENOTYPE_GVCFS` | Joint genotyping across the cohort |
| 12 | `BCFTOOLS_FILTER` | Variant filtering |
| 13 | `SNPEFF` | Functional variant annotation |

## Requirements

- [Nextflow](https://www.nextflow.io/) (DSL2, v22.10+ recommended)
- [Docker](https://www.docker.com/) **or** [Conda](https://docs.conda.io/) / Mamba
- Java 17+ (for Nextflow and GATK)
- Reference genome and GATK resource bundle (see **Inputs**)

Enabled by default in `nextflow.config`:

```groovy
docker.enabled = true
conda.enabled  = true
```

## Inputs

### Samplesheet

A CSV file with a header row and the following columns:

| Column | Description |
|--------|-------------|
| `sample` | Sample identifier |
| `lane` | Sequencing lane (used to distinguish multiple lanes of the same sample) |
| `fastq_1` | Path to R1 FASTQ |
| `fastq_2` | Path to R2 FASTQ |

Example `data/samplesheet.csv`:

```csv
sample,lane,fastq_1,fastq_2
SAMPLE1,L001,/path/to/S1_L001_R1.fastq.gz,/path/to/S1_L001_R2.fastq.gz
SAMPLE1,L002,/path/to/S1_L002_R1.fastq.gz,/path/to/S1_L002_R2.fastq.gz
SAMPLE2,L001,/path/to/S2_L001_R1.fastq.gz,/path/to/S2_L001_R2.fastq.gz
```

Multiple lanes for the same sample are merged after alignment and before duplicate marking.

### Reference files

| Parameter | Default | Description |
|-----------|---------|-------------|
| `reference_bwa` | `data/ref/human_g1k_v37_decoy.fasta` | Reference for BWA indexing |
| `reference` | `data/WholeGenomeFasta/human_g1k_v37_decoy.fasta` | Reference for GATK |
| `reference_index` | `...fasta.fai` | FASTA index |
| `reference_dict` | `...fasta.dict` | Sequence dictionary |
| `known_sites` | `data/Annotation/GATKBundel/dbsnp_138.b37.vcf.gz` | Known sites for BQSR |
| `intervals` | `data/ref/intervals.bed` | Target intervals for calling |

## Usage

```bash
nextflow run Zengxiang-Zhao/nextflow \
    -profile docker \
    --input data/samplesheet.csv \
    --outdir results
```

Or from a local clone:

```bash
git clone https://github.com/Zengxiang-Zhao/nextflow.git
cd nextflow
nextflow run main.nf -profile docker
```

Override reference paths as needed:

```bash
nextflow run main.nf \
    --input  data/samplesheet.csv \
    --reference_bwa /ref/human_g1k_v37_decoy.fasta \
    --reference     /ref/human_g1k_v37_decoy.fasta \
    --known_sites   /ref/dbsnp_138.b37.vcf.gz \
    --outdir        results
```

Resume a previous run:

```bash
nextflow run main.nf -resume
```

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--input` | `data/samplesheet.csv` | Samplesheet CSV |
| `--outdir` | `results` | Output directory |
| `--reference_bwa` | `data/ref/...` | Reference FASTA for BWA |
| `--reference` | `data/WholeGenomeFasta/...` | Reference FASTA for GATK |
| `--reference_index` | `...fai` | FASTA index |
| `--reference_dict` | `...dict` | Sequence dictionary |
| `--known_sites` | `dbsnp_138.b37.vcf.gz` | Known sites for BQSR |
| `--intervals` | `data/ref/intervals.bed` | Calling intervals |
| `--cohort_name` | `test_cohort` | Cohort label for joint genotyping |

## Outputs

Results are written to `${params.outdir}` (default: `results/`), organized per process:

```
results/
├── fastqc/                     # FastQC HTML/ZIP reports
├── bwa/                        # Sorted BAMs
├── markduplicates/             # Duplicate-marked BAMs
├── samtools_stats/             # Alignment stats (pre-BQSR)
├── samtools_stats_post_bqsr/   # Alignment stats (post-BQSR)
├── mosdepth/                   # Coverage (pre-BQSR)
├── mosdepth_post_bqsr/         # Coverage (post-BQSR)
├── base_recalibrator/          # BQSR recalibration tables
├── apply_bqsr/                 # Recalibrated BAMs
├── haplotype_caller/           # Per-sample GVCFs
├── genotype_gvcfs/             # Joint-genotyped VCF
├── bcftools_filter/            # Filtered VCF
└── snpeff/                     # Annotated VCF
```

## Environment Configuration

The default config uses a shared Conda environment:

```groovy
process {
    conda = "/pathTo/miniconda3/envs/ngs"

    withName: SNPEFF {
        conda = "/pathTo/miniconda3/envs/snpEff"
    }
}
```

> **Note:** Update `/pathTo/miniconda3/envs/ngs` and `/pathTo/miniconda3/envs/snpEff`
> to match your local installation paths before running.

When using Docker, the `conda` directives are ignored if `-profile docker` is active
(depending on your profile definitions). Add profiles in `nextflow.config` if you want
to toggle between Docker, Singularity, and Conda.

## Notes & Recommendations

- The reference genome in this pipeline is **GRCh37 / b37** (`human_g1k_v37_decoy`).
  Make sure `known_sites`, `intervals`, and SnpEff database are all b37-compatible.
- Duplicate marking is performed **per sample** after merging lanes.
- BQSR is applied before variant calling; coverage is reported both before and after.
- The final VCF is filtered with `bcftools filter` and then annotated with SnpEff.

## Author

**Zengxiang Zhao**
GitHub: [@Zengxiang-Zhao](https://github.com/Zengxiang-Zhao)
