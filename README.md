# Nextflow Pipelines

A collection of reproducible Nextflow pipelines for common next-generation sequencing (NGS) analysis workflows. Each pipeline is self-contained, Docker/Conda-friendly, and designed for portability across local machines, HPC clusters, and cloud environments.

## Pipelines

| Pipeline | Description | Directory |
|----------|-------------|-----------|
| **RNA-seq Analysis** | End-to-end paired-end RNA-seq analysis — QC, trimming, alignment, quantification, differential expression, and functional enrichment. Converted from the systemPipeR workflow to Nextflow. | [`RNAseq/`](./RNAseq) |
| **Germline Variant Calling** | Whole-genome/whole-exome germline variant calling — QC, alignment, duplicate marking, BQSR, GATK HaplotypeCaller, joint genotyping, filtering, and SnpEff annotation. | [`DNAseq/`](./DNAseq) |

---

## RNA-seq Analysis Pipeline

A comprehensive Nextflow pipeline for paired-end RNA-seq data analysis, reimplemented from the **systemPipeR** workflow to avoid R package installation and version compatibility issues.

### Features

- **Quality Control**: FastQC on raw and trimmed reads
- **Read Trimming**: Trim Galore for adapter and quality trimming
- **Quality Reporting**: MultiQC aggregation of QC metrics
- **Alignment**: HISAT2 alignment to reference genome
- **Alignment Statistics**: Flagstat and custom alignment metrics
- **Gene Quantification**: FeatureCounts for gene-level counts
- **Sample Clustering**: Sample tree/dendrogram generation
- **Differential Expression**: edgeR-based analysis
- **Visualization**: Venn diagrams, heatmaps, volcano plots
- **Functional Enrichment**: GO enrichment analysis

### Workflow

```
Raw Paired-End Reads (FASTQ)
         │
         ▼
    ┌─────────┐
    │ FastQC  │
    └────┬────┘
         │
         ▼
  ┌─────────────┐
  │ Trim Galore │
  └──────┬──────┘
         │
         ├──────────────────┐
         ▼                  ▼
    ┌─────────┐       ┌──────────┐
    │ MultiQC │       │  HISAT2  │
    └─────────┘       └────┬─────┘
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
        ┌──────────┐ ┌───────────┐ ┌─────────────┐
        │ Align    │ │ Feature   │ │  Sample     │
        │ Stats    │ │ Counts    │ │  Tree       │
        └────┬─────┘ └─────┬─────┘ └─────────────┘
             │             │
             ▼             ▼
        ┌──────────┐ ┌───────────┐
        │ Collect  │ │  edgeR    │
        │ Stats    │ │  Analysis │
        └──────────┘ └─────┬─────┘
                           │
              ┌────────────┼────────────┬────────────┐
              ▼            ▼            ▼            ▼
          ┌───────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐
          │ Venn  │  │ GO Rich │  │ Heatmap │  │ Volcano │
          └───────┘  └─────────┘  └─────────┘  └─────────┘
```

### Quick Start

```bash
nextflow run main.nf \
    --input /path/to/targetsPE.txt \
    --hisat2_index /path/to/hisat2_index.tar.gz \
    --gtf /path/to/annotation.gtf \
    --report_id my_experiment
```

Or with the test profile:

```bash
nextflow run main.nf -profile test
```

👉 **See [`RNAseq/README.md`](./RNAseq/README.md) for full documentation**, including input format, parameters, output structure, modules, and R scripts.

---

## Germline Variant Calling Pipeline

A Nextflow (DSL2) pipeline for whole-genome/whole-exome germline variant calling, from raw FASTQ reads through to annotated VCF.

### Features

- **Read QC**: FastQC
- **Alignment**: BWA + sorting, with multi-lane merging per sample
- **Duplicate Marking**: Picard MarkDuplicates (per sample)
- **Base Quality Score Recalibration**: GATK BaseRecalibrator + ApplyBQSR
- **Coverage Statistics**: Mosdepth (pre- and post-BQSR)
- **Alignment Statistics**: Samtools stats (pre- and post-BQSR)
- **Variant Calling**: GATK HaplotypeCaller (per-sample GVCFs)
- **Joint Genotyping**: GenotypeGVCFs across the cohort
- **Filtering**: bcftools filter
- **Annotation**: SnpEff

### Workflow

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

### Quick Start

```bash
nextflow run Zengxiang-Zhao/nextflow \
    -profile docker \
    --input data/samplesheet.csv \
    --outdir results
```

Or from a local clone:

```bash
git clone https://github.com/Zengxiang-Zhao/nextflow.git
cd nextflow/DNAseq
nextflow run main.nf -profile docker
```

👉 **See [`DNAseq/README.md`](./DNAseq/README.md) for full documentation**, including samplesheet format, reference files, parameters, output structure, and environment configuration.

---

## Repository Structure

```
nextflow/
├── README.md                 # This file
├── RNAseq/                   # RNA-seq analysis pipeline
│   ├── main.nf
│   ├── nextflow.config
│   ├── modules/
│   ├── scripts/
│   └── README.md
└── DNAseq/                   # Germline variant calling pipeline
    ├── main.nf
    ├── nextflow.config
    ├── modules/
    └── README.md
```

---

## General Requirements

Both pipelines share common requirements:

- [Nextflow](https://www.nextflow.io/) (>= 22.10, DSL2)
- [Docker](https://www.docker.com/) **or** [Conda](https://docs.conda.io/) / Mamba
- Java 17+ (for Nextflow and GATK)
- Reference data appropriate for each pipeline (see individual READMEs)

Docker is enabled by default in both pipelines for reproducibility. Conda environments can be used as an alternative where configured.

---

## Citation

If you use these pipelines in your research, please cite the underlying tools. Tool-specific citations are listed in each pipeline's README, including:

- **Nextflow**: Di Tommaso et al. (2017) *Nature Biotechnology*
- **systemPipeR**: Backman & Girke (2016) *Briefings in Bioinformatics*
- **FastQC**, **Trim Galore**, **HISAT2**, **FeatureCounts**, **edgeR**, **MultiQC** (RNA-seq)
- **BWA**, **GATK**, **Samtools**, **Mosdepth**, **bcftools**, **SnpEff** (DNAseq)

---

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request or open an issue for bug reports and feature requests.

---

## Contact

**Zengxiang Zhao**
GitHub: [@Zengxiang-Zhao](https://github.com/Zengxiang-Zhao)

For questions or issues, please open an issue on GitHub.
