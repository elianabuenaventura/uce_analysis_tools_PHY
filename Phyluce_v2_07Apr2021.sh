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



#Trinity Submission Scripts for Hydra 3
#Creo este bash script "2.trinity_submission.sh" y lo pongo en /pool/genomics/buenaventurae/sarc
#OJO debe estar fuera del folder "clean-fastq"

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

#Creo este job "trinity.job" y lo pongo en /pool/genomics/buenaventurae/sarc
#OJO debe estar fuera del folder "clean-fastq"

```
module load bioinformatics/trinity/r2013_2_25
Trinity --CPU $NSLOTS --seqType fq --JM 50G --left $LOC/split-adapter-quality-trimmed/$TAXON-READ1_cat.fastq.gz --right $LOC/split-adapter-quality-trimmed/$TAXON-READ2.fastq.gz --full_cleanup --min_kmer_cov 2 --output $OUTDIR/$TAXON
rm -r $OUTDIR/$TAXON
rm $LOC/split-adapter-quality-trimmed/$TAXON-READ1_cat.fastq.gz $LOC/split-adapter-quality-trimmed/$TAXON-READ1_cat.fastq  $LOC/split-adapter-quality-trimmed/$TAXON-READ2.fastq
```

#LUEGO

#corro chmod +x 2.trinity_submission.sh

#Y luego...
#Para someter el 2.trinity_submission.sh y el trinity.job entonces voy a /pool/genomics/buenaventurae/sarc
# y copio esta linea de codigo

#para lane 1
> nohup ./2.trinity_submission.sh /pool/genomics/buenaventurae/sarc/park/clean-fastq /pool/genomics/buenaventurae/sarc/trinity_assemblies_park /pool/genomics/buenaventurae/sarc/trinity.job > trin_submission_nohup.out&


#para L2
> nohup ./2.trinity_submission.sh /pool/genomics/buenaventurae/sarc/perk/clean-fastq /pool/genomics/buenaventurae/sarc/trinity_assemblies_perk /pool/genomics/buenaventurae/sarc/trinity.job > trin_submission_nohup.out&




#Post Trinity Clean up:
#Rename Trinity Assemblies with esta linea de codigo
> cd trinity_assemblies/
> rename .Trinity.fasta .contigs.fasta *.Trinity.fasta

#After renaming, move trinity assemblies to a directory called ./contigs/

> cd mkdir contigs
> mv /pool/genomics/buenaventurae/uce/trinity_assemblies/*.fasta /pool/genomics/buenaventurae/uce/trinity_assemblies/contigs 

#for L2
> cd mkdir contigs
> mv /pool/genomics/buenaventurae/nuce/trinity_assemblies/*.fasta /pool/genomics/buenaventurae/nuce/trinity_assemblies/contigs 

#to merge the L1 and L2
> mv /pool/genomics/buenaventurae/uce/trinity_assemblies/contigs/*.fasta /pool/genomics/buenaventurae/nuce/trinity_assemblies/contigs 




##You may want to get stats on these raw fastas by running something like the following:

## get summary stats on the raw FASTAS using job Contigstats.job


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




###The following is for the entire dataset = L1 + L2

#Continuing Phyluce
#Match contigs to probe set: Here I will Get contigs that match the probe set

# I prepared this job 1.match_to_probe.job

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

#Someter 
>qsub 1.match_to_probe.job 

#El .log del job 1.match_to_probe.job me muestra cuantos loci únicos se recuperaron por especie! <3
# si quiero ver esto en forma de tabla entonces:

> cd /pool/genomics/buenaventurae/barc/sarc/matched_probe_trin_70_80
>sqlite3 probe.matches.sqlite
.mode columns
.headers on
.nullvalue 0
.output matches_uce.txt
SELECT * FROM matches;
.exit



#Create the data matrix configuration file (taxon_list.conf)

[oestroidea]
EB_23
EB_20
EB_39
EB_110
EB_42
EB_45
EB_52
EB_53
EB_54
EB_21
EB_55
EB_35
EB_59
EB_61
EB_62
EB_122
EB_128
EB_129
EB_63
EB_71
EB_134
EB_76
EB_138
EB_141
EB_144
EB_x002
EB_79
EB_80
EB_81
EB_0a
EB_82
EB_0b
EB_83
EB_14
EB_17
EB_19
EB_22
EB_84
EB_145
EB_146
EB_147
EB_85
EB_86
EB_148
EB_149
EB_87
EB_5
EB_150
EB_151
EB_152
EB_1
EB_33
EB_153
EB_88
EB_6
EB_x287
EB_x285
EB_13
EB_156
EB_157
EB_90
EB_89
EB_91
EB_92
EB_7
EB_93
EB_32
EB_94
EB_4
EB_95
EB_12
EB_96
EB_97
EB_98
EB_36
EB_99
EB_100
EB_159
EB_31
EB_16
EB_101
EB_9
EB_30
EB_x256
EB_x230
EB_x066
EB_x187
EB_27
EB_x062
EB_x239
EB_x240
EB_x067
EB_x089
EB_102
EB_x193
EB_29
EB_x143
EB_x160
EB_x098
EB_0c
EB_x088
EB_26
EB_x096
EB_x254
EB_x184
EB_x123
EB_34
EB_15
EB_x248
EB_x021
EB_x068
EB_x007
EB_x072
EB_28
EB_x045
EB_x197
EB_x030
EB_103
EB_24
EB_x229
EB_x228
EB_8
EB_x140
EB_25
EB_2
EB_38
EB_104
EB_162
EB_105
EB_106
EB_163
EB_107
EB_164
EB_3
EB_108
EB_109
T_1200
T_1201
T_1195
T_1185
T_1160



#INDIVIDUAL DATASETS SET:
#Create directory for each 'set' analyzed.
 > mkdir oestroidea

 
#Get match counts: create this job: 2.get_match_counts.job

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

#Submit

> qsub 2.get_match_counts.job





#Extracting FASTA dataphyluce_assembly_get_fastas_from_match_counts (3.fasta_from_match.job)

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

#luego submit
>qsub 3.fasta_from_match.job




#Hice qsub 3i.explode_fasta.job desde /pool/genomics/buenaventurae/sarc


""""

# /bin/sh
# ----------------Parameters---------------------- #
#$ -S /bin/sh
#$ -q lThC.q
#$ -l mres=2G,h_data=2G,h_vmem=2G
#$ -cwd
#$ -j y
#$ -N ExplodeFastas
#$ -o ExplodeFastas.log
#
# ----------------Modules------------------------- #
module load bioinformatics/phyluce/1.5_tg
#
# ----------------Your Commands------------------- #
#

phyluce_assembly_explode_get_fastas_file \
    --input /pool/genomics/buenaventurae/sarc/oestroidea/incomplete_matrix.fasta \
    --output-dir /pool/genomics/buenaventurae/sarc/oestroidea/exploded-fastas \
    --by-taxon
"""

### OJO!!! El output log file del job '3i.explode_fasta.job' es MUY simple y esta bien!
## Loading bioinformatics/phyluce/1.5_tg
##  Loading requirement: gcc/4.9.2 tools/mthread-numpy
##Reading fasta...
##Writing fasta...



##You may want to get stats on these exploded-fastas by running something like the following:

## get summary stats on the exploded-FASTAS using job ContigsStats_uces.job


"""
# /bin/sh
# ----------------Parameters---------------------- #
#$ -S /bin/sh
#$ -q lThC.q
#$ -l mres=2G,h_data=2G,h_vmem=2G
#$ -cwd
#$ -j y
#$ -N ContigsStats_uces
#$ -o ContigsStats_uces.log
#
# ----------------Modules------------------------- #
module load bioinformatics/phyluce/1.5_tg
#
# ----------------Your Commands------------------- #
#

for i in /pool/genomics/buenaventurae/sarc/oestroidea/exploded-fastas/*.fasta;
do phyluce_assembly_get_fasta_lengths --input $i --csv;
done


"""




#Aligning and trimming FASTA data phyluce_align_seqcap_align (4.align_fasta.job)

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

#luego submit
>qsub 4.align_fasta.job






#GBLOCKS (5.gblocks.job)

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

#luego submit
> qsub 5.gblocks.job




###Summary Stats align_summary.job

```
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

```



###Reduce dataset to a certain percentage of missing data. [here it is 70%] (6.min_taxa_reduction.job)

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

#luego submit
> qsub 6.min_taxa_reduction.job





#Locus name removal and add missing data to each UCE locus so that concatenation can happen (7.data_desig.job).

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

#luego submit
> qsub 7.data_desig.job




#Formatting for RAxML - concatenated run (8.RAxML_Concat.job).

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


#luego submit
> qsub 8.RAxML_Concat.job





###RAxML Run (9.RAxML_run.job):
#Run with RAxML best tree + 100 bootstrap search. Unpartitioned data

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

#luego submit
> qsub 9.RAxML_run.job

oest_ana_3 Set up to sun on 8-Jul-2019 at 18:23:34 -> Finish on 9-Jul-2019 at 15:22
oest_ana_3b Set up to sun on 8-Jul-2019 at 18:45:34 -> Finish on 10-Jul-2019 at 17:02

Finish on 

__________________________________________________________

###PHASING UCES

##To phase your UCE data, you need to have individual-specific “reference” contigs 
##against which to align your raw reads. 
##Generally speaking, you can create these individual-specific reference contigs at 
##several stages of the phyluce pipeline, and ##the stage at which you choose to do this 
##may depend on the analyses that you are running. That said, I think that the best way 
##to proceed uses edge-trimmed exploded alignments as your reference contigs, aligns 
##raw reads to those, and uses the exploded ##alignments and raw reads to phase your 
##data.(text copied from the Phyluce tutorial for phasing)

##the first is getting my reference contigs in a folder structure to follow the phasing
##tutorial. In the start of phasing tutorial, they send you to the "Edge trimming" section
## that is in the tutorial "Tutorial I: UCE phylogenomics" under "Aligning UCE loci". So
## the first I do is to run my job 4b.align_fasta_edge_trimmed.job to get my reference 
## contigs in the folder /pool/genomics/buenaventurae/sarc/oestroidea/mafft-nexus-edge-trimmed/

#Hice qsub 4b.align_fasta_edge_trimmed.job desde /pool/genomics/buenaventurae/sarc

"""

# /bin/sh
# ----------------Parameters---------------------- #
#$ -S /bin/sh
#$ -pe mthread 6
#$ -q lThC.q
#$ -l mres=6G,h_data=6G,h_vmem=6G
#$ -cwd
#$ -j y
#$ -N AlignFastaTrimmed
#$ -o AlignFastaTrimmed.log
#
# ----------------Modules------------------------- #
module load bioinformatics/phyluce/1.5_tg
#
# ----------------Your Commands------------------- #
#

phyluce_align_seqcap_align \
    --fasta /pool/genomics/buenaventurae/sarc/oestroidea/incomplete_matrix.fasta \
    --output /pool/genomics/buenaventurae/sarc/oestroidea/mafft-nexus-edge-trimmed/ \
    --taxa 141 \
    --aligner mafft \
    --cores 6 \
    --output-format nexus \
    --incomplete-matrix


"""


##El resultado son mis reference contigs in /pool/genomics/buenaventurae/sarc/oestroidea/mafft-nexus-edge-trimmed/




## adicionalmente, corri el siguiente código para obtender estadisticas de los reference contigs


module load bioinformatics/phyluce/1.5_tg
phyluce_align_get_align_summary_data \
    --alignments /pool/genomics/buenaventurae/sarc/oestroidea/mafft-nexus-edge-trimmed

## el resultado esta en align_summary_mafft-nexus-edge-trimmed.txt



###Exploding aligned and trimmed UCE sequences


##After doing the Edge Trimming with 4b.align_fasta_edge_trimmed.job, then now 
##you can “explode” the directory of alignments you have generated to create separate 
##FASTA files for each individual using the following (this assumes your alignments are 
##in mafft-nexus-edge-trimmed as in the tutorial).

##Para hacer esto creo el job 10.exploded_trimmed_uces.job 

#Hice qsub 10.exploded_trimmed_uces.job desde /pool/genomics/buenaventurae/sarc


""""

# /bin/sh
# ----------------Parameters---------------------- #
#$ -S /bin/sh
#$ -q sThC.q
#$ -l mres=1G,h_data=1G,h_vmem=1G
#$ -cwd
#$ -j y
#$ -N ExplodeTrimmedUCEs
#$ -o ExplodeTrimmedUCEs.log
#
# ----------------Modules------------------------- #
module load bioinformatics/phyluce/1.5_tg
#
# ----------------Your Commands------------------- #
#

phyluce_align_explode_alignments \
    --alignments /pool/genomics/buenaventurae/sarc/oestroidea/mafft-nexus-edge-trimmed/ \
    --input-format nexus \
    --output /pool/genomics/buenaventurae/sarc/oestroidea/mafft-nexus-edge-trimmed-exploded/ \
    --by-taxon

"""


##You may want to get stats on these exploded-fastas by running something like the following:

## get summary stats on the FASTAS
for i in mafft-nexus-edge-trimmed-exploded/*.fasta;
do
    phyluce_assembly_get_fasta_lengths --input $i --csv;
done


##al hacer esto obtuve un resumen de cada taxon con su nombre (=sample), reads, total bp, mean
## length,  95 CI length, min, max, median
##esta info esta guardada en ExplodeTrimmedUCEs_summarystats.csv



###Creating a re-alignment configuration file

##Before aligning raw reads back to these reference contigs using bwa, you have to create 
##a configuration file, which tells the program where the cleaned and trimmed fastq reads 
##are stored for each sample and where to find the reference FASTA file for each sample. 
##The configuration file should look like in the following example and should be saved as 
##e.g. phasing.conf


##I put my phasing.conf in the folder /pool/genomics/buenaventurae/sarc/snp_phasing/phasing.conf



###Mapping reads against contigs

##To map the fastq read files against the contig reference database for each sample, 
##run the following. This will use bwa mem to map the raw reads to the “reference” contigs:


##Para hacer esto creo el job 11.mnet-exploded-phasing-multialign-bams.job 

#Hice qsub 11.mnet-exploded-phasing-multialign-bams.job desde /pool/genomics/buenaventurae/sarc


"""

# /bin/sh 
# ----------------Parameters---------------------- #
#$  -S /bin/sh
#$ -pe mthread 6
#$ -q lThC.q
#$ -l mres=36G,h_data=6G,h_vmem=6G
#$ -cwd
#$ -j y
#$ -N mnet-exploded-multialign-bams
#$ -o mnet-exploded-multialign-bams.log
#
# ----------------Modules------------------------- #
module load bioinformatics/phyluce
#
# ----------------Your Commands------------------- #
#
echo + `date` job $JOB_NAME started in $QUEUE with jobID=$JOB_ID on $HOSTNAME
echo + NSLOTS = $NSLOTS
#
phyluce_snp_bwa_multiple_align \
    --config ./snp_phasing/phasing.conf \
    --output /pool/genomics/buenaventurae/sarc/oestroidea/mnet-exploded-multialign-bams \
    --cores 6 \
    --mem
#
echo = `date` job $JOB_NAME done


"""

#El resultado son mis clean raw reads que están clean-fasta alineadas contra mis reference contigs para cada taxon
#El resultado está en /pool/genomics/buenaventurae/sarc/oestroidea/mnet-exploded-multialign-bams


###Phasing mapped reads

##In the previous step you aligned your sequence reads against the reference FASTA file for
## each sample. The results are stored in the output folder in bam format. Now you can 
##start the actual phasing of the reads. This will analyze and sort the reads within 
##each bam file into two separate bam files (genus_species1.0.bam and genus_species1.1.bam).

##The program is very easy to run and just requires the path to the bam files (output folder 
##from previous mapping program, /path/to/mapping_results) and the path to the configuration 
##file, which is the same file as used in the previous step (/path/to/phasing.conf). Then, run:

##Para hacer esto creo el job 12.phasing_bams.job 

#Hice qsub 12.phasing_bams.job desde /pool/genomics/buenaventurae/sarc

"""

# /bin/sh
# ----------------Parameters---------------------- #
#$ -S /bin/sh
#$ -pe mthread 2
#$ -q lThC.q
#$ -l mres=8G,h_data=4G,h_vmem=4G
#$ -cwd
#$ -j y
#$ -N phasing_bams
#$ -o phasing_bams.log
#
# ----------------Modules------------------------- #
module load bioinformatics/phyluce
#
# ----------------Your Commands------------------- #
#
echo + `date` job $JOB_NAME started in $QUEUE with jobID=$JOB_ID on $HOSTNAME
echo + NSLOTS = $NSLOTS
#
phyluce_snp_phase_uces \
    --config ./snp_phasing/phasing.conf \
    --bams /pool/genomics/buenaventurae/sarc/oestroidea/mnet-exploded-multialign-bams \
    --output /pool/genomics/buenaventurae/sarc/oestroidea/multialign-bams-phased-reads
#
echo = `date` job $JOB_NAME done

"""

##The program automatically produces a consensus sequence for each of these phased bam 
##files (= allele sequence) and stores these allele sequences of all samples in a joined 
##FASTA file (joined_allele_sequences_all_samples.fasta). This allele FASTA is deposited 
##in the subfolder fastas within your output folder 
##(i.e. /pool/genomics/buenaventurae/sarc/oestroidea/multialign-bams-phased-reads/fastas/).

##You can directly input that file (joined_allele_sequences_all_samples.fasta) back into 
##the alignment pipeline, like so:

##Para hacer esto creé los jobs job 13sa.align_fasta_sinuceambiguous.job y 13ca.align_fasta_conuceambiguous.job

## El job 13sa.align_fasta_sinuceambiguous.job descarta todos los UCEs que tengan bases ambiguas. 
## Al ejecurtarlo se recuperan 2378 UCEs (78,458,561 bytes)

## Dado que ese job descarta tantos UCEs, diseñé otro job, 13ca.align_fasta_conuceambiguous.job, en el que se mantienen
## todos los UCES así tengan bases ambiguas. Al ejecutarlo se recuperan 2361 UCEs (120,060,567 bytes)

## nótese que el aunque el job 13ca recupera menos UCEs que el job 13sa, la cantidad de bytes es mayor. 



##job 13sa.align_fasta_sinuceambiguous.job

"""
# /bin/sh
# ----------------Parameters---------------------- #
#$ -S /bin/sh
#$ -pe mthread 6
#$ -q lThC.q
#$ -l mres=36G,h_data=6G,h_vmem=6G
#$ -cwd
#$ -j y
#$ -N Phasing_AlignFasta_ambiguous
#$ -o Phasing_AlignFasta_ambiguous.log
#
# ----------------Modules------------------------- #
module load bioinformatics/phyluce
#
# ----------------Your Commands------------------- #
#
echo + `date` job $JOB_NAME started in $QUEUE with jobID=$JOB_ID on $HOSTNAME
echo + NSLOTS = $NSLOTS
#
phyluce_align_seqcap_align \
    --fasta /pool/genomics/buenaventurae/sarc/oestroidea/multialign-bams-phased-reads/fastas/joined_allele_sequences_all_samples.fasta \
    --output /pool/genomics/buenaventurae/sarc/oestroidea/mafft-fasta-phased-uces \
    --min-length 100 \
    --taxa 141 \
    --aligner mafft \
    --cores $NSLOTS \
    --output-format fasta \
    --incomplete-matrix
#
echo = `date` job $JOB_NAME done

"""


##job 13ca.align_fasta_conuceambiguous.job

"""
# /bin/sh
# ----------------Parameters---------------------- #
#$ -S /bin/sh
#$ -pe mthread 6
#$ -q lThC.q
#$ -l mres=36G,h_data=6G,h_vmem=6G
#$ -cwd
#$ -j y
#$ -N Phasing_AlignFasta_ambiguous
#$ -o Phasing_AlignFasta_ambiguous.log
#
# ----------------Modules------------------------- #
module load bioinformatics/phyluce
#
# ----------------Your Commands------------------- #
#
echo + `date` job $JOB_NAME started in $QUEUE with jobID=$JOB_ID on $HOSTNAME
echo + NSLOTS = $NSLOTS
#
phyluce_align_seqcap_align \
    --fasta /pool/genomics/buenaventurae/sarc/oestroidea/multialign-bams-phased-reads/fastas/joined_allele_sequences_all_samples.fasta \
    --output /pool/genomics/buenaventurae/sarc/oestroidea/mafft-fasta-phased-uce-ambiguous \
    --min-length 100 \
    --taxa 141 \
    --aligner mafft \
    --ambiguous \
    --cores $NSLOTS \
    --output-format fasta \
    --incomplete-matrix
#
echo = `date` job $JOB_NAME done

"""

#Hice qsub 13sa.align_fasta_sinuceambiguous.job y 13ca.align_fasta_conuceambiguous.job desde /pool/genomics/buenaventurae/sarc



"""
# /bin/sh
# ----------------Parameters---------------------- #
#$ -S /bin/sh
#$ -pe mthread 6
#$ -q lThC.q
#$ -l mres=36G,h_data=6G,h_vmem=6G
#$ -cwd
#$ -j y
#$ -N MINTAXA_phasedUCE_noambiguous
#$ -o 13y_MINTAXA_phasedUCE_noambiguous.log
#
# ----------------Modules------------------------- #
module load bioinformatics/phyluce
#
# ----------------Your Commands------------------- #
#
echo + `date` job $JOB_NAME started in $QUEUE with jobID=$JOB_ID on $HOSTNAME
echo + NSLOTS = $NSLOTS
#
phyluce_align_get_only_loci_with_min_taxa \
    --alignments /pool/genomics/buenaventurae/sarc/oestroidea/mafft-fasta-phased-uces/ \
    --taxa 141 \
    --percent 0.70 \
    --output /pool/genomics/buenaventurae/sarc/oestroidea/mafft-nexus-phaseduces-70per-taxa/ \
    --cores $NSLOTS
#
echo = `date` job $JOB_NAME done
"""
