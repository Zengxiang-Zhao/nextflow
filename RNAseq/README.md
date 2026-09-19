# RNA-seq Analysis Pipeline

A comprehensive Nextflow pipeline for paired-end RNA-seq data analysis, converted from the **systemPipeR** workflow to overcome R package installation and version compatibility challenges.

## Background

This pipeline is based on the **systemPipeR** analysis steps but reimplemented as a Nextflow workflow. The original systemPipeR R package can be difficult to install due to R package version dependencies and compatibility issues. By converting the workflow to Nextflow, this pipeline provides:

- **Reproducibility** through Docker containers
- **Scalability** for HPC and cloud environments
- **Portability** across different systems
- **Easier installation** without complex R package dependencies

## Overview

This pipeline performs end-to-end RNA-seq analysis including:

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

## Pipeline Workflow

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

## Requirements

### Software

- [Nextflow](https://www.nextflow.io/) (>= 22.10)
- [Docker](https://www.docker.com/) (enabled by default)

### Reference Data

- HISAT2 index (tar.gz)
- GTF annotation file

### Test Data (from systemPipeRdata)

The test data can be generated using the R package `systemPipeRdata`:

```r
Rscript -e "systemPipeRdata::genWorkenvir(workflow='rnaseq', mydirname='rnaseq')"
```

This creates a `rnaseq` folder containing:
- `data/` — Sample FASTQ files
- `targetsPE.txt` — Sample metadata file

## Input Format

The pipeline expects a tab-separated metadata file (`targetsPE.txt`). The first 4 lines are skipped as comments/metadata.

### Example targetsPE.txt

```
# Project ID: Arabidopsis - Pseudomonas alternative splicing study (SRA: SRP010938; PMID: 24098335)
# The following line(s) allow to specify the contrasts needed for comparative analyses, such as DEG identification. All possible comparisons can be specified with 'CMPset: ALL'.
# <CMP> CMPset1: M1-A1, M1-V1, A1-V1, M6-A6, M6-V6, A6-V6, M12-A12, M12-V12, A12-V12
# <CMP> CMPset2: ALL
FileName1	FileName2	SampleName	Factor	SampleLong	Experiment	Date
/path/to/SRR446027_1.fastq.gz	/path/to/SRR446027_2.fastq.gz	M1A	M1	Mock.1h.A	1	23-Mar-2012
/path/to/SRR446028_1.fastq.gz	/path/to/SRR446028_2.fastq.gz	M1B	M1	Mock.1h.B	1	23-Mar-2012
/path/to/SRR446029_1.fastq.gz	/path/to/SRR446029_2.fastq.gz	A1A	A1	Avr.1h.A	1	23-Mar-2012
/path/to/SRR446030_1.fastq.gz	/path/to/SRR446030_2.fastq.gz	A1B	A1	Avr.1h.B	1	23-Mar-2012
/path/to/SRR446031_1.fastq.gz	/path/to/SRR446031_2.fastq.gz	V1A	V1	Vir.1h.A	1	23-Mar-2012
```

| Column | Description |
|--------|-------------|
| `FileName1` | Path to R1 FASTQ file |
| `FileName2` | Path to R2 FASTQ file |
| `SampleName` | Unique sample identifier |
| `Factor` | Experimental factor/condition |
| `SampleLong` | Descriptive sample name |
| `Experiment` | Experiment name |
| `Date` | Date of experiment |

## Usage

### Basic Run

```bash
nextflow run main.nf \
    --input /path/to/targetsPE.txt \
    --hisat2_index /path/to/hisat2_index.tar.gz \
    --gtf /path/to/annotation.gtf \
    --report_id my_experiment
```

### Using the Test Profile

```bash
nextflow run main.nf -profile test
```

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `--input` | Path to `targetsPE.txt` metadata file | Yes |
| `--hisat2_index` | Path to HISAT2 index (tar.gz) | Yes |
| `--gtf` | Path to GTF annotation file | Yes |
| `--report_id` | Identifier for the analysis run | Yes |

## Output Structure

```
results/
├── fastqc/              # FastQC reports (raw reads)
├── trimming/            # Trimmed reads and trimming reports
├── multiqc/             # MultiQC aggregated report
├── alignment/           # Sorted BAM files and HISAT2 logs
├── stats/               # Alignment statistics
├── counts/              # Gene count matrices
├── sample_tree/         # Sample dendrogram
├── edgeR/               # Differential expression results
├── venn/                # Venn diagrams
├── go_rich/             # GO enrichment results
├── heatmap/             # Expression heatmaps
└── volcano/             # Volcano plots
```

## Modules

| Module | Description |
|--------|-------------|
| `FASTQC_PE` | Quality control for paired-end reads |
| `TRIM_GALORE_PE` | Adapter and quality trimming |
| `MULTIQC` | Aggregate QC reports |
| `HISAT2_ALIGN` | Genome alignment |
| `ALIGN_STATS` | Alignment statistics (flagstat) |
| `COLLECT_STATS` | Collect alignment metrics |
| `FEATURE_COUNTS` | Gene-level quantification |
| `SAMPLE_TREE` | Sample clustering dendrogram |
| `RUN_EDGER` | Differential expression analysis |
| `VENN` | Venn diagram generation |
| `GO_RICH` | GO enrichment analysis |
| `HEATMAP` | Expression heatmap |
| `DRAW_VELCANO` | Volcano plot generation |

## Scripts

R scripts are located in the `scripts/` directory:

| Script | Purpose |
|--------|---------|
| `sample_tree.R` | Generate sample dendrogram |
| `run_edge.R` | Perform edgeR differential expression |
| `draw_venn.R` | Create Venn diagrams |
| `go_rich.R` | GO enrichment analysis |
| `draw_heatmap.R` | Generate expression heatmaps |
| `draw_volcano.R` | Create volcano plots |

## Docker

The pipeline uses Docker containers for reproducibility. A custom Docker image is provided for R-based analysis steps (GO enrichment, heatmaps, volcano plots).

### Building the Custom Docker Image

```bash
cd scripts
docker build -t my-r-env:devel .
```

## Configuration

### nextflow.config

```groovy
docker.enabled = true

profiles {
    test {
        params.input = '/path/to/targetsPE.txt'
        params.hisat2_index = '/path/to/index.tar.gz'
        params.report_id = 'test_run'
        params.gtf = '/path/to/annotation.gtf'
    }
}

process {
    withName: 'MULTIQC' {
        publishDir = [
            path: "/path/to/multiqc/output",
            mode: 'copy'
        ]
    }
}
```

## Directory Structure

```
.
├── main.nf                 # Main workflow script
├── nextflow.config         # Pipeline configuration
├── modules/                # Nextflow process modules
│   ├── align_stats.nf
│   ├── collect_stats.nf
│   ├── draw_velcano.nf
│   ├── draw_venn.nf
│   ├── fastqc_pe.nf
│   ├── feature_counts.nf
│   ├── go_rich.nf
│   ├── heatmap.nf
│   ├── hisat2_align.nf
│   ├── multiqc.nf
│   ├── run_edge.nf
│   ├── sample_tree.nf
│   └── trim_galore_pe.nf
└── scripts/                # R scripts and Dockerfile
    ├── Dockerfile
    ├── draw_heatmap.R
    ├── draw_venn.R
    ├── draw_volcano.R
    ├── go_rich.R
    ├── run_edge.R
    └── sample_tree.R
```

## Getting Test Data

Install the `systemPipeRdata` R package and generate the test environment:

```r
# Install systemPipeRdata
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("systemPipeRdata")

# Generate workflow environment
systemPipeRdata::genWorkenvir(workflow = "rnaseq", mydirname = "rnaseq")
```

This will create a `rnaseq/` directory containing the `data/` folder and `targetsPE.txt` file used by the test profile.


## Comparison with systemPipeR

| Step | systemPipeR | This Pipeline |
|------|-------------|---------------|
| QC | `seeFastq` | FastQC + MultiQC |
| Trimming | `preprocessReads` | Trim Galore |
| Alignment | `alignRsubread`/`Hisat2` | HISAT2 |
| Quantification | `summarizeOverlaps` | FeatureCounts |
| DE Analysis | `run_edgeR` | edgeR (R script) |
| Enrichment | `goRich` | GO enrichment (R script) |
| Visualization | Various R functions | Dedicated R scripts |

## Citation

If you use this pipeline in your research, please cite the tools used:

- **systemPipeR**: Backman & Girke (2016) Briefings in Bioinformatics
- **Nextflow**: Di Tommaso et al. (2017) Nature Biotechnology
- **FastQC**: Andrews S. (2010) Babraham Bioinformatics
- **Trim Galore**: Krueger F. Babraham Bioinformatics
- **HISAT2**: Kim et al. (2019) Nature Biotechnology
- **FeatureCounts**: Liao et al. (2014) Bioinformatics
- **edgeR**: Robinson et al. (2010) Bioinformatics
- **MultiQC**: Ewels et al. (2016) Bioinformatics


## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Contact

For questions or issues, please open an issue on GitHub.
