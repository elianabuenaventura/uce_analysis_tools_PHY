# uce_analysis_tools

## Phyluce_v2_07Apr2021.sh is a pipeline for uce analysis 
This is an analysis pipeline (based on Phyluce) for analyzing data collected from ultraconserved elements in organismal genomes on the Smithsonian computer cluster Hydra3.

This is a wrapper shell script for automating the Phyluce pipeline starting from trimming adapter contamination from SE and PE illumina reads with Illumiprocessor to statistical maximum-likelihood analysis with RAxML. Predesigned jobs for running the scripts are included in the pipeline.

It includes scripts that allow for:
* sequence quality checks with Illumiprocessor
* contig assembly with Trinity 
* identification of UCE contigs, parallel alignment generation and alignment trimming with phyluce scripts
* alignment data with MAFFT
* phylogenomic analysis with RAxML

This version has been tested only on a cluster (Hydra3). If you try it and there are problems, let me know. 

## Python script to parse and create nice output from match_contigs_log from Phyluce
This script parses the log file from phyluce_assembly_match_contigs_to_probes to more easily and nicely presented output locus, contig etc. counts.

```
python match_contigs_log_parse_to_nice_output.py [-h] Infile (Outfile)
```

Where 'Infile' is the logfile produced by phyluce_assembly_match_contigs_to_probes.

