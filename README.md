# uce_analysis_tools

This is an analysis pipeline (based on Phyluce) for analyzing data collected from ultraconserved elements in organismal genomes on the Smithsonian computer cluster Hydra3.

This is a wrapper shell script for automating the Phyluce pipeline starting from trimming adapter contamination from SE and PE illumina reads with Illumiprocessor to statistical maximum-likelihood analysis with RAxML. Predesigned jobs for running the scripts are included in the pipeline.

## The associated scripts allow for:
* sequence quality checks with Illumiprocessor
* contig assembly with Trinity 
* Identification of UCE contigs, parallel alignment generation and alignment trimming with phyluce scripts
* alignment data with MAFFT
* phylogenomic analysis with RAxML

This version has been tested only on a cluster (Hydra3). If you try it and there are problems, let me know. 

