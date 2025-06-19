# module-07-penghy27  
Date: November 14th, 2022  
Purpose: Aligning RNA sequences reads of sea anemones (*Aiptasia pallida*).

The following is working on Discovery. Running this alignment in /scratch/username/ with a computing node.

# Short read alignment of RNA-seq with GSNAP

## Overview  
This project contains scripts and instructions for trimming reads, building reference genome indexes, aligning reads to a reference genome, and performing post-alignment processing (such as converting SAM to BAM files and indexing BAM files) using various bioinformatics tools. We use short-read aligners like GSNAP, which are splice-aware and can handle the complexity of RNA-Seq data. 

## Methods  
### 1. Data 
The input data for this assignment is a subset of an RNA-Seq experiment to study immune response and symbiosis in sea anemones (*Aiptasia pallida*). There were four treatment groups and six replicates per treatment group for a total of 24 anemones. (Data provided by the professor)

### 2. Quality Trimming

**Tool Used: [Trimmomatic](http://www.usadellab.org/cms/?page=trimmomatic)**

Trimmomatic is a Java-based tool for trimming low-quality bases from sequencing reads and removing adapter sequences. It utilizes a sliding window approach to assess the quality of reads and trim sequences where quality scores drop below a specified threshold. Trimmomatic also removes any adapter sequences, which can interfere with alignment and downstream analysis.

- Script: `AipTrim.sh`
- Input: Raw FASTQ files (data/rawreads/)
- Output: Trimmed FASTQ files (data/trimmed/)

### 3. Building GMAP/GSNAP Database 

**Tool Used:** [GMAP](https://academic.oup.com/bioinformatics/article/21/9/1859/409207) `gmap_build` (from the GMAP/GSNAP suite)

We build a reference database using `gmap_build` to index the reference genome. This step prepares the reference for efficient and splice-aware alignment with **GSNAP**. The indexed database enables **GSNAP** to perform fast and accurate read mapping by recognizing exon-intron boundaries.

- Script: `AipBuild.sh`
- Input: Reference genome in FASTA format (e.g., Aiptasia_genome.fa)
- Optional Input: GFF3 file to generate known splice site information (can be used with --use-splicing)
- Output: Indexed GMAP/GSNAP database directory

**Note:** GMAP and GSNAP share the same database format. This database must be built once before performing alignment.


### 4. Alignment with GSNAP

**Tool Used:**  [GSNAP](http://research-pub.gene.com/gmap/) `gsnap` — Genomic Short-read Nucleotide Alignment Program  

We use **GSNAP** to align trimmed RNA-seq reads to the reference genome. **GSNAP** is a splice-aware aligner, capable of handling exon–intron boundaries and gapped alignments, making it suitable for eukaryotic RNA-seq data. It uses the database built by gmap_build to support high-performance alignment.

- Script: `alignReads.sh`
- Input: Trimmed paired-end FASTQ files and GMAP/GSNAP database
- Output: Alignment results in SAM format

Note: GSNAP's output can be further processed by SAMtools to convert into sorted BAM files for downstream transcriptome assembly or quantification.


### 5. SAM to BAM Conversion and Sorting

**Tool Used: [Samtools](http://www.htslib.org)**

Aligned SAM files are converted to the more compact BAM format and sorted for efficient storage and downstream processing. This step is essential as most bioinformatics tools require sorted BAM files.

- Script: `sortAlign.sh`
- Input: Aligned SAM files
- Output: Sorted BAM files

### 6. Indexing BAM Files

**Tool Used: [Samtools](http://www.htslib.org)**

To facilitate quick access and visualization of BAM files, we index them using Samtools. Indexing is crucial for various downstream applications, including variant calling and data visualization.

- Script: `indexSam.sh`
- Input: Sorted BAM files
- Output: BAM index files

### 7.Multi-File Processing and Automation

To handle multiple samples efficiently, we use shell scripting to automate the processing pipeline. The multi-file shell scripts iterate through all available samples, perform quality trimming, alignment, conversion, and indexing, reducing manual intervention and errors.

- Scripts: `findSampleNames.sh`, `listSamples.sh`, `trimAll.sh`
- Purpose: Automate processing steps across multiple RNA-Seq samples


## Usage

1. **Quality Trimming**: Run `AipTrim.sh` to trim raw FASTQ files.
2. **Build GMAP Database**: Run `AipBuild.sh` to create the GMAP database.
3. **Align Reads**: Execute `alignReads.sh` to align reads to the reference genome using GSNAP.
4. **Sort and Index BAM Files**: Use `sortAlign.sh` and `indexSam.sh` for BAM file processing.
5. **Automate Pipeline**: Run `trimAll.sh` for automated multi-file processing.


## Reference
- Lamolle, G., Musto, H. Why Prokaryotes Genomes Lack Genes with Introns Processed by Spliceosomes?. J Mol Evol 86, 611–612 (2018). https://doi.org/10.1007/s00239-018-9874-4  
- Baruzzo, G., Hayer, K. E., Kim, E. J., Di Camillo, B., FitzGerald, G. A., & Grant, G. R. (2017). Simulation-based comprehensive benchmarking of RNA-seq aligners. Nature Methods, 14(2), 135–139. https://doi.org/10.1038/nmeth.4106  

