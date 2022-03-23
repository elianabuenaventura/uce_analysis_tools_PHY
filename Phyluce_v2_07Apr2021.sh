#!/bin/sh

# Sequential running of Phyluce pipeline with parallel Trinity implementation for use on Hydra3.   
# Eliana Buenaventura
# 07-04-21



# Illumiprocessor

# IMPORTANT – CHANGE NAMES
## You should place reads (all the *.txt.gz files) from different lanes, separately, on separated folders. 
## Before you trim your sequences, file names neen to be changed. You will add a 0 after X on file names. 

## for example
## "15066X6_180427_D00294_0392_BCCEA1ANXX_5_1.txt.gz" for "15066X06_180427_D00294_0392_BCCEA1ANXX_5_1.txt.gz"

## to add a 0 after X you run this line of code:
> for filename in 15066X0*; do echo mv \"$filename\" \"${filename//15066X0/15066X}\"; done

## output exmaple
mv "15066X5_180427_D00294_0392_BCCEA1ANXX_5_2.txt.gz.md5" "15066X05_180427_D00294_0392_BCCEA1ANXX_5_2.txt.gz.md5"
mv "15066X6_180427_D00294_0392_BCCEA1ANXX_5_1.txt.gz" "15066X06_180427_D00294_0392_BCCEA1ANXX_5_1.txt.gz"
mv "15066X6_180427_D00294_0392_BCCEA1ANXX_5_1.txt.gz.md5" "15066X06_180427_D00294_0392_BCCEA1ANXX_5_1.txt.gz.md5"
mv "15066X6_180427_D00294_0392_BCCEA1ANXX_5_2.txt.gz" "15066X06_180427_D00294_0392_BCCEA1ANXX_5_2.txt.gz"
mv "15066X6_180427_D00294_0392_BCCEA1ANXX_5_2.txt.gz.md5" "15066X06_180427_D00294_0392_BCCEA1ANXX_5_2.txt.gz.md5"
mv "15066X7_180427_D00294_0392_BCCEA1ANXX_5_1.txt.gz" "15066X07_180427_D00294_0392_BCCEA1ANXX_5_1.txt.gz"

## Leave your .md5 files into the original folder (p.e., 15066R or 15138R) where you also have copies of all raw reads.



# COUNTS OF READS
## To get counts of raw reads (*.txt.gz), go to the directory where raw reads are and run the following line of code

>find . -type f -name '*5_1.txt.gz' -exec bash -c 'echo -n $(basename {} _180427_D00294_0392_BCCEA1ANXX_5_1.txt.gz)",";gunzip -c $1 | echo $((`wc -l`/4)) ' dummy {} \;>read_countsL1.csv



# OBTAIN CLEAN .fastq READS

## Generate the required configuration file: 
## Conf File (illumi.conf)
## Make sure to add the 0 after the X on file names

## example of your illumi.conf

"""
[adapters]
i7:GATCGGAAGAGCACACGTCTGAACTCCAGTCAC*ATCTCGTATGCCGTCTTCTGCTTG
i5:AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT*GTGTAGATCTCGGTGGTCGCCGTATCATT

[tag sequences]
i7-iTru7_1:GGTAGTGT
i7-iTru7_2:CAACGGAT
i7-iTru7_3:TACGGTTG
i7-iTru7_4:CAAGTGCA
i7-iTru7_5:ATGCACGA
i7-iTru7_6:AGCAAGCA
i7-iTru7_7:CTAGGTGA
i7-iTru7_8:ACTGAGGT
i7-iTru7_9:CACTGACA
i7-iTru7_10:CAGTCCAA
i7-iTru7_11:TCGACATC
i7-iTru7_12:GAGTCTCT
i5-iTru5_A:AACACCAC
i5-iTru5_B:TGAGCTGT
i5-iTru5_C:CACAGGAA
i5-iTru5_D:CTGTATGC
i5-iTru5_E:CTTAGGAC
i5-iTru5_F:TCAGCCTT
i5-iTru5_G:ACATGCCA
i5-iTru5_H:CAGTGCTT

[tag map]
15066X01:i7-iTru7_1,i5-iTru5_A
15066X02:i7-iTru7_1,i5-iTru5_B
15066X03:i7-iTru7_1,i5-iTru5_C
15066X04:i7-iTru7_1,i5-iTru5_D
15066X05:i7-iTru7_1,i5-iTru5_E
15066X06:i7-iTru7_1,i5-iTru5_F
15066X07:i7-iTru7_1,i5-iTru5_G
15066X08:i7-iTru7_1,i5-iTru5_H
15066X09:i7-iTru7_2,i5-iTru5_A
15066X10:i7-iTru7_2,i5-iTru5_B


[names]
15066X01:EB_0a
15066X02:EB_0b
15066X03:EB_0c
15066X04:EB_1
15066X05:EB_2
15066X06:EB_3
15066X07:EB_4
15066X08:EB_5
15066X09:EB_6
15066X10:EB_7
"""



# CREATE YOUR illumi.job
## Remember to Change the r1/r2 pattern to match the endings of your sequence files, and the input directory name (if not in /raw_reads). 
## Your illumi.job will create clean files of your reads

## Make sure you have the correct folder structure
## You should have a folder name fx. 'park'. Inside /park you should have a folder 'raw_reads' where you have the files of raw reads (*.txt.gz)
## Thus, you should have this structure fx. /pool/genomics/buenaventurae/sarc/park/raw_reads
## Your illumi.job and illumi.conf files should be in /park
## You should qsub your illumi.job from folder /park
## The output files will be placed in a folder called clean-fastq 


#### Hydra Job File (illumi.job)  

# /bin/sh
# ----------------Parameters---------------------- #
#$ -S /bin/sh
#$ -pe mthread 4
#$ -q mThC.q
#$ -l mres=8G,h_data=2G,h_vmem=2G
#$ -cwd
#$ -j y
#$ -N illumi
#$ -o illumiprocessor.log
#
# ----------------Modules------------------------- #
module load bioinformatics/phyluce/1.5_tg
#
# ----------------Your Commands------------------- #
#
echo + `date` job $JOB_NAME started in $QUEUE with jobID=$JOB_ID on $HOSTNAME
echo + NSLOTS = $NSLOTS
#
illumiprocessor --input raw_reads \
--output clean-fastq \
--config illumi.conf \
--r1-pattern {}_180427_D00294_0392_BCCEA1ANXX_5_1.txt.gz \
--r2-pattern {}_180427_D00294_0392_BCCEA1ANXX_5_2.txt.gz \
--cores $NSLOTS
#
echo = `date` job $JOB_NAME done



# TRINITY SUBMISSION SCRIPTS FOR Hydra 3
## Below, you will create a bash script and a job: "2.trinity_submission.sh" and "trinity.job"

## Create this bash script "2.trinity_submission.sh" and place it on /pool/genomics/buenaventurae/sarc
## CAREFUL: this bash script should not be inside folder "clean-fastq"

```
#!/bin/sh
module load bioinformatics/trinity/r2013_2_25

me=`basename "$0"`

#check syntax
if [ $# -ne 3 ]; then
    echo Script needs directory input.
    echo Script usage: $me ./path/to/uce-clean ./path/to/output-dir ./path/to/job-file
    exit 1
fi

#get variables
workdir=$(readlink -e  $1)
outputdir=$(readlink -f $2)
jobfile=$(readlink -e $3)

#check jobfile existence
if [ ! -f "$jobfile" ]; then 
    echo "Cant find job-file $jobfile check if it exists."
    exit 1
fi

#check outdir existence
if [ -d $outputdir ]; then
    echo "Directory '$outputdir/$taxon' exists, check output directory to avoid overwrite."
    exit 1
else
    mkdir $outputdir
fi

#check logfile existence
if [ -d $outputdir/job_logs ]; then
    echo "Log directory '$outputdir/job_logs' exists"
else
    mkdir $outputdir/job_logs
fi

#####

#loop over taxa
for ARQ in $workdir/*
do

q-wait -njobs 10 -wait 900 trinity

taxon=`basename "$ARQ"`;

#check if taxon directory is present.
if [ -d $outputdir/$taxon ]; then
    echo "Directory '$outputdir/$taxon' exists, check output directory to avoid overwrite."
    exit 1
else
    mkdir $outputdir/$taxon
fi

#concat read1 and singletons if needed. 
#submit to hydra
if [ -e $ARQ/split-adapter-quality-trimmed/$taxon-READ1_cat.fastq.gz ]; then
    echo "Cat file for $taxon already exists. Submitting."
    qsub -q lThM.q -N trinity -S /bin/sh -cwd -o $outputdir/job_logs/job_$taxon.out -v TAXON=$taxon,LOC=$ARQ,OUTDIR=$outputdir -j y -l mres=50G,h_data=50G,h_vmem=50G,himem, -pe mthread 4 $jobfile
else
    echo "Adding singletons onto R1 for $taxon, then submitting."
    cat $ARQ/split-adapter-quality-trimmed/$taxon-READ-singleton.fastq.gz $ARQ/split-adapter-quality-trimmed/$taxon-READ1.fastq.gz > $ARQ/split-adapter-quality-trimmed/$taxon-READ1_cat.fastq.gz
    #rm $ARQ/split-adapter-quality-trimmed/$taxon-READ1.fastq.gz $ARQ/split-adapter-quality-trimmed/$taxon-READ-singleton.fastq.gz
    #The coverage script needs the R1 and Singleton files as they are, and not combined. 
    #To avoid filling the drive with too many files, the job file now deletes the '*_cat' file.  
    qsub -q lThM.q -N trinity -S /bin/sh -cwd -o $outputdir/job_logs/job_$taxon.out -v TAXON=$taxon,LOC=$ARQ,OUTDIR=$outputdir -j y -l mres=50G,h_data=50G,h_vmem=50G,himem, -pe mthread 4 $jobfile
fi

done
```

## Create this job "trinity.job" and place it on /pool/genomics/buenaventurae/sarc
## CAREFUL: this bash script should not be inside folder "clean-fastq"

```
module load bioinformatics/trinity/r2013_2_25
Trinity --CPU $NSLOTS --seqType fq --JM 50G --left $LOC/split-adapter-quality-trimmed/$TAXON-READ1_cat.fastq.gz --right $LOC/split-adapter-quality-trimmed/$TAXON-READ2.fastq.gz --full_cleanup --min_kmer_cov 2 --output $OUTDIR/$TAXON
rm -r $OUTDIR/$TAXON
rm $LOC/split-adapter-quality-trimmed/$TAXON-READ1_cat.fastq.gz $LOC/split-adapter-quality-trimmed/$TAXON-READ1_cat.fastq  $LOC/split-adapter-quality-trimmed/$TAXON-READ2.fastq
```

## Once your job and bash script are created you do the following steps 1 and 2

## In step 1 you run:
chmod +x 2.trinity_submission.sh

## In step 2 you go to /pool/genomics/buenaventurae/sarc and run your bash script and job:
> nohup ./2.trinity_submission.sh /pool/genomics/buenaventurae/sarc/park/clean-fastq /pool/genomics/buenaventurae/sarc/trinity_assemblies_park /pool/genomics/buenaventurae/sarc/trinity.job > trin_submission_nohup.out&



# POST TRINITY CLEAN UP
## Rename Trinity Assemblies with esta linea de codigo
> cd trinity_assemblies/
> rename .Trinity.fasta .contigs.fasta *.Trinity.fasta



# MOVE TRINITY ASSEMBLIES
## After renaming, move trinity assemblies to a directory called ./contigs/

> cd mkdir contigs
> mv /pool/genomics/buenaventurae/uce/trinity_assemblies/*.fasta /pool/genomics/buenaventurae/uce/trinity_assemblies/contigs 



# TRINITY STATS
## You may want to get stats on these raw fastas by running something like the following:
## get summary stats on the raw FASTAS using job Contigstats.job

#### Hydra Job File (Contigstats.job)  

"""
# /bin/sh
# ----------------Parameters---------------------- #
#$ -S /bin/sh
#$ -q lThC.q
#$ -l mres=2G,h_data=2G,h_vmem=2G
#$ -cwd
#$ -j y
#$ -N ContigsStats
#$ -o ContigsStats.log
#
# ----------------Modules------------------------- #
module load bioinformatics/phyluce/1.5_tg
#
# ----------------Your Commands------------------- #
#

for i in /pool/genomics/buenaventurae/sarc/trinity_assemblies/contigs/*.fasta;
do phyluce_assembly_get_fasta_lengths --input $i --csv;
done

"""



# PHYLUCE STARTS HERE

# MATCH CONTIGS TO PROBE SET
## Match contigs to probe set: Here I will Get contigs that match the probe set
## Submit your job 
>qsub 1.match_to_probe.job 

#### Hydra Job File (1.match_to_probe.job)

"""
# /bin/sh
# ----------------Parameters---------------------- #
#$ -S /bin/sh
#$ -q lThC.q
#$ -l mres=2G,h_data=2G,h_vmem=2G
#$ -cwd
#$ -j y
#$ -N MatchToProbes
#$ -o MatchToProbes.log
#
# ----------------Modules------------------------- #
module load bioinformatics/phyluce/1.5_tg
#
# ----------------Your Commands------------------- #
#
phyluce_assembly_match_contigs_to_probes \
--contigs /pool/genomics/buenaventurae/sarc/trinity_assemblies/contigs \
--probes /pool/genomics/buenaventurae/sarc/probes/probes_Oestroidea_v2.fasta \
--output /pool/genomics/buenaventurae/sarc/matched_probe_trin_70_80/ \
--min-coverage 70 \
--min-identity 80 

"""



## The .log file from job 1.match_to_probe.job shows how many loci were recovered per species
## To see this in a table format you run:

> cd /pool/genomics/buenaventurae/barc/sarc/matched_probe_trin_70_80
>sqlite3 probe.matches.sqlite
.mode columns
.headers on
.nullvalue 0
.output matches_uce.txt
SELECT * FROM matches;
.exit



#CREATE THE DATA MATRIX CONFIGURAITON FILE (taxon_list.conf)

"""
[oestroidea]
EB_0a
EB_0b
EB_0c
EB_1
EB_2
EB_3
EB_4
EB_5
EB_6
EB_7
"""



# INDIVIDUAL DATASETS SET
## Create directory for each 'set' analyzed.
 > mkdir oestroidea

 
 
# GET MATCH COUNTS
## Get match counts: create this job: 2.get_match_counts.job
## Submit
> qsub 2.get_match_counts.job

#### Hydra Job File (2.get_match_counts.job)  

"""
# /bin/sh
# ----------------Parameters---------------------- #
#$ -S /bin/sh
#$ -q sThC.q
#$ -l mres=1G,h_data=1G,h_vmem=1G
#$ -cwd
#$ -j y
#$ -N GetMatchCount
#$ -o GetMatchCount.log
#
# ----------------Modules------------------------- #
module load bioinformatics/phyluce/1.5_tg
#
# ----------------Your Commands------------------- #
#

phyluce_assembly_get_match_counts \
    --locus-db /pool/genomics/buenaventurae/uce/OestroideaL1_v2/matched_probe_trin_70_80/probe.matches.sqlite \
    --taxon-list-config /pool/genomics/buenaventurae/uce/OestroideaL1_v2/taxon_list.conf \
    --taxon-group 'oestroidea1L' \
    --output  /pool/genomics/buenaventurae/uce/OestroideaL1_v2/incomplete_matrix.conf \
    --incomplete-matrix \
    --extend-locus-db /pool/genomics/buenaventurae/uce/OestroideaL1_v2/matched_probe_trin_70_80/probe.matches.sqlite

"""



# GET FASTAS
## Now, we need to extract FASTA data that correspond to the loci in your data matrix configuration file
## Submit
> qsub 3.fasta_from_match.job

#### Hydra Job File (3.fasta_from_match.job)  

"""
# /bin/sh
# ----------------Parameters---------------------- #
#$ -S /bin/sh
#$ -q lThC.q
#$ -l mres=2G,h_data=2G,h_vmem=2G
#$ -cwd
#$ -j y
#$ -N GetFastas
#$ -o GetFastas.log
#
# ----------------Modules------------------------- #
module load bioinformatics/phyluce/1.5_tg
#
# ----------------Your Commands------------------- #
#

phyluce_assembly_get_fastas_from_match_counts \
    --contigs /pool/genomics/buenaventurae/uce/OestroideaL1_v2/trinity_assemblies/contigs \
    --locus-db /pool/genomics/buenaventurae/uce/OestroideaL1_v2/matched_probe_trin_70_80/probe.matches.sqlite \
    --match-count-output /pool/genomics/buenaventurae/uce/OestroideaL1_v2/incomplete_matrix.conf \
    --incomplete-matrix /pool/genomics/buenaventurae/uce/OestroideaL1_v2/incomplete_matrix.incomplete \
    --output /pool/genomics/buenaventurae/uce/OestroideaL1_v2/incomplete_matrix.fasta \
    --extend-locus-db /pool/genomics/buenaventurae/uce/OestroideaL1_v2/matched_probe_trin_70_80/probe.matches.sqlite \
    --extend-locus-contigs /pool/genomics/buenaventurae/uce/OestroideaL1_v2/trinity_assemblies/contigs

"""



# ALIGN FASTA 
## Aligning and trimming FASTA data phyluce_align_seqcap_align (4.align_fasta.job)
## There are many options for aligning UCE loci: use  alignments with no trimming, edge-trim the alignments or end+internally trim alignments. 
## When taxa are “closely” related (< 30-50 MYA, perhaps), edge-trimming alignments is reasonable. 
## When the taxa span a wider range of divergence times (> 50 MYA), internal trimming could be a better option.
## Phyluce implements edge-trimming by running the alignment program “as-is” (i.e., without the –no-trim) option. 
## The pipeline below uses mafft as aligner.

## Edge trimming
## Submit
> qsub 4.align_fasta.job

#### Hydra Job File (4.align_fasta.job)  

"""
# /bin/sh
# ----------------Parameters---------------------- #
#$ -S /bin/sh
#$ -pe mthread 6
#$ -q lThC.q
#$ -l mres=6G,h_data=6G,h_vmem=6G
#$ -cwd
#$ -j y
#$ -N AlignFasta
#$ -o AlignFasta.log
#
# ----------------Modules------------------------- #
module load bioinformatics/phyluce/1.5_tg
#
# ----------------Your Commands------------------- #
#

phyluce_align_seqcap_align \
    --fasta /pool/genomics/buenaventurae/sarc/oestroidea/incomplete_matrix.fasta \
    --output /pool/genomics/buenaventurae/sarc/oestroidea/mafft-fasta/ \
    --no-trim \
    --min-length 100 \
    --taxa 141 \
    --aligner mafft \
    --cores 6 \
    --output-format fasta \
    --incomplete-matrix

"""



# GBLOCKS 
## Now we trim these loci using Gblocks
## Submit
> qsub 5.gblocks.job

#### Hydra Job File (5.gblocks.job)

"""
# /bin/sh
# ----------------Parameters---------------------- #
#$ -S /bin/sh
#$ -pe mthread 6
#$ -q lThC.q
#$ -l mres=6G,h_data=6G,h_vmem=6G
#$ -cwd
#$ -j y
#$ -N GBLOCKS
#$ -o GBLOCKS.log
#
# ----------------Modules------------------------- #
module load bioinformatics/phyluce/1.5_tg
#
# ----------------Your Commands------------------- #
#
phyluce_align_get_gblocks_trimmed_alignments_from_untrimmed \
    --alignments /pool/genomics/buenaventurae/uce/OestroideaL1_v2/mafft-fasta/ \
    --output /pool/genomics/buenaventurae/uce/OestroideaL1_v2/mafft-nexus-gblocks/ \
    --input-format fasta \
    --output-format nexus \
    --b1 0.5 \
    --b2 0.5 \
    --b3 12 \
    --b4 7 \
    --cores 6

"""



# SUMMARY STATS
## Here we will get stats of our aligments 
## Submit
> qsub align_summary.job

#### Hydra Job File (align_summary.job)


"""
# /bin/sh
# ----------------Parameters---------------------- #
#$ -S /bin/sh
#$ -q mThC.q
#$ -l mres=6G,h_data=6G,h_vmem=6G
#$ -cwd
#$ -j y
#$ -N AlignSummary_Sarc
#$ -o AlignSummary_Sarc.log
#
# ----------------Modules------------------------- #
module load bioinformatics/phyluce
#
# ----------------Your Commands------------------- #
#

phyluce_align_get_align_summary_data \
--alignments /pool/genomics/buenaventurae/sarc/oestroidea/mafft-nexus-gblocks/

"""



# REDUCE DATASET TO A PERCENTAGE OF MISSING DATA
## Reduce dataset to a certain percentage of missing data. [here it is 70%] 
## Submit
> qsub 6.min_taxa_reduction.job

#### Hydra Job File (6.min_taxa_reduction.job)

"""
# /bin/sh
# ----------------Parameters---------------------- #
#$ -S /bin/sh
#$ -pe mthread 6
#$ -q lThC.q
#$ -l mres=6G,h_data=6G,h_vmem=6G
#$ -cwd
#$ -j y
#$ -N MINTAXA
#$ -o MINTAXA.log
#
# ----------------Modules------------------------- #
module load bioinformatics/phyluce/1.5_tg
#
# ----------------Your Commands------------------- #
#
phyluce_align_get_only_loci_with_min_taxa \
    --alignments /pool/genomics/buenaventurae/uce/OestroideaL1_v2/mafft-nexus-gblocks/ \
    --taxa 96 \
    --percent 0.70 \
    --output /pool/genomics/buenaventurae/uce/OestroideaL1_v2/mafft-nexus-70per-taxa/ \
    --cores 6

"""



# DATA DESIGN
## Design datasets: This involves locus name removal and add missing data to each UCE locus so that concatenation can happen.
## Submit
> qsub 7.data_desig.job

#### Hydra Job File (7.data_desig.job)

"""
# /bin/sh
# ----------------Parameters---------------------- #
#$ -S /bin/sh
#$ -pe mthread 6
#$ -q lThC.q
#$ -l mres=6G,h_data=6G,h_vmem=6G
#$ -cwd
#$ -j y
#$ -N DATADESIG
#$ -o DATADESIG.log
#
# ----------------Modules------------------------- #
module load bioinformatics/phyluce/1.5_tg
#
# ----------------Your Commands------------------- #
#
phyluce_align_add_missing_data_designators  \
    --alignments /pool/genomics/buenaventurae/uce/OestroideaL1_v2/mafft-nexus-70per-taxa/ \
    --output /pool/genomics/buenaventurae/uce/OestroideaL1_v2/mafft-nexus-min-70per-taxa \
    --match-count-output /pool/genomics/buenaventurae/uce/OestroideaL1_v2/incomplete_matrix.conf \
    --incomplete-matrix /pool/genomics/buenaventurae/uce/OestroideaL1_v2/incomplete_matrix.incomplete \
    --cores 6

"""



# PREPARE YOUR DATASET FOR PHYLOGENOMIC ANALYSIS USING MAXIMUM-LIKELIHOOD
## This script will do Formatting for RAxML to run a concatenated analysis.
## Submit
> qsub 8.RAxML_Concat.job

#### Hydra Job File (8.RAxML_Concat.job)

"""
# /bin/sh
# ----------------Parameters---------------------- #
#$ -S /bin/sh
#$ -q lThC.q
#$ -l mres=6G,h_data=6G,h_vmem=6G
#$ -cwd
#$ -j y
#$ -N RAxMLConcat
#$ -o RAxMLConcat.log
#
# ----------------Modules------------------------- #
module load bioinformatics/phyluce/1.5_tg
#
# ----------------Your Commands------------------- #
#
phyluce_align_format_nexus_files_for_raxml \
    --alignments /pool/genomics/buenaventurae/uce/OestroideaL1_v2/mafft-nexus-min-70per-taxa \
    --output /pool/genomics/buenaventurae/uce/OestroideaL1_v2/raxml_70per/ \
    --charsets

"""



# RUN YOUR PHYLOGENOMIC ANALYSIS
## Run with RAxML best tree + 100 bootstrap search. Unpartitioned data.
## Submit
> qsub 9.RAxML_run.job

#### Hydra Job File (9.RAxML_run.job)

"""
# /bin/sh
# ----------------Parameters---------------------- #
#$ -S /bin/sh
#$ -pe mthread 20
#$ -q lThC.q
#$ -l mres=6G,h_data=6G,h_vmem=6G
#$ -cwd
#$ -j y
#$ -N RAxML
#$ -o RAxML.log

# ----------------Modules------------------------- #
module load bioinformatics/raxml/8.2.12
#
# ----------------Your Commands------------------- #
#
echo + `date` job $JOB_NAME started in $QUEUE with jobID=$JOB_ID on $HOSTNAME
echo + NSLOTS = $NSLOTS distributed over:sort $TMPDIR/machines | uniq -c
#
raxmlHPC-PTHREADS-SSE3 -s /pool/genomics/buenaventurae/barc/sarc141/sarc141-concat-70/mafft-nexus-gblocks-70-min.phylip -m GTRCAT -w /pool/genomics/buenaventurae/barc/sarc141/sarc141-concat-70 -n sarc141_uce_analysis -f a -T $NSLOTS -N 100 -p 3523423 -x 34589776

#
echo = `date` job $JOB_NAME done
"""


