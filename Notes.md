## Sep 10

Note: switched from bananas to cherries: 'gcloud compute ssh cherries-controller'
Had trouble setting up google sdk on my local terminal (new mac). Fixed it with the following steps. 

The default shell is probably zsh; checked with "echo $SHELL". Got /bin/zsh, changed using "chsh -s /bin/bash"\
Then followed steps at 'https://cloud.google.com/sdk/docs/downloads-interactive?authuser=1#linux-mac'\

Terminal did not recognize command 'gcloud'

Fixed this by following the directions here: https://stackoverflow.com/questions/31037279/gcloud-command-not-found-while-installing-google-cloud-sdk\

Essentially, I used these two commands:

source '/Users/cottonellezhou/google-cloud-sdk/path.bash.inc'
source '/Users/cottonellezhou//google-cloud-sdk/completion.bash.inc'

For time zone, select option 2\
After those steps, I can now access google sdk on my local terminal.

## 9.14

Apparently, I must run source '/Users/cottonellezhou/google-cloud-sdk/path.bash.inc' every time I reopen the terminal

Background: 
M-pipiens molestus, don’t bite
P-pipiens pipiens, bite
Found differences when Sarah did RNAseq- on mRNA (with polyAAA tail)
Now we are looking at files of size selected small RNAs- pi RNAs, miRNAs, etc, but data was from same individuals/RNA samples

Goal: 1. download and run these 6 files through FastQC

$ gsutil ls gs://gu-biology-pi-paa9/culexBiting_smallRNA/rawData

- M1_S4_L001_R1_001.fastq.gz
- M2_S5_L001_R1_001.fastq.gz
- M4_S6_L001_R1_001.fastq.gz
- P1_S1_L001_R1_001.fastq.gz
- P2_S2_L001_R1_001.fastq.gz
- P3_S3_L001_R1_001.fastq.gz

Ran [script](https://github.com/AngelaZhou779/RISE/blob/main/script/FastQC.sh) called fastqc in folder called script in folder called RISE
It finished running in about 45min
Result: 6 .zip files and 6 .html files

Bring the html files back to local to veiw in web format (run command from local device)
```
Cottonelles-MBP:~ cottonellezhou$ gcloud compute scp cherries-controller:/home/zz220/RISE/fastqc_out/*_fastqc.html .
```



## 9.18

Counting reads of the raw files
```
wc -l M1_S4_L001_R1_001.fastq 
```
Count the number of lines using wc -l and then divide by 4

## 9.29
To clean the files, I ran the following [trimmomatic script](https://github.com/AngelaZhou779/RISE/blob/main/script/Trimmomatic.sh).

Trimmomatic (version 0.39) was used to trim sequence reads based on quality ([script](https://github.com/AngelaZhou779/RISE/blob/main/script/Trimmomatic.sh))

FastQC (v0.11.9) was used for quality control visualization ([script](https://github.com/srmarzec/Culex_Biting_RNAseq/blob/main/Upstream/fastqc.sh))

Preliminary trimming and fastqc showed a poor "per sequence base content" for the first few bases. Therefore, we used headcrop four in the begginning, but there is no command to crop the four at the end which could be any base pairs. Note that SE settings were used. 

In addition, we removed the adapter sequences for the Illumina small RNA 3' adapter, which can be found [here]. (https://github.com/AngelaZhou779/RISE/blob/main/miscellaneous/smalladaptercontent.md) 
 
These sequences were obtained after contacting those that did the illlumina sequencing and asking for the exact adapter sequences used. Also, all the cleaned files will have the annotation: .cln.fastq
This file can also be found the the trimmomatic folder of my account with the following path: /home/zz220/trimmomatic/Trimmomatic-0.39/adapters/smRNA_NexFlex_adapters.fa

Afterwards I ran the files through fastqc using the [following fastqc script](https://github.com/AngelaZhou779/RISE/blob/main/script/fastqc_clnfiles.sh).

Bring the html files back to local to veiw in web format (run command from local):
```
gcloud compute scp cherries-controller:/home/zz220/RISE/fastqc_out/*.cln_fastqc.html .
```

From the fastqc files, you can see that the per base sequences quality improved and the adapter content was removed. Around 80% of the reads are left after cleaning, although there are still red flags for the following:
[FAIL]Per base sequence content
[FAIL]Per sequence GC content
[WARNING]Sequence Length Distribution
[FAIL]Sequence Duplication Levels
[FAIL]Overrepresented sequences 


## 10.15
Aim: to remove tRNA and other contaminates. Note: raw files were removed from my folder. Trimmed files (with the adapters removed) have the extension cln_fastqc.html

We removed tRNA and rRNA sequences that we obtained from NCBI Culex quinquefasciatus mitochondrion, complete genome. The full link can be found [here](https://www.ncbi.nlm.nih.gov/nucleotide/NC_014574.1)

First tried the following methodolgy on one data file: M1_S4_L001_R1_001.ctn.bam
To make index:

to find how to build the index: 
$bowtie2-build –h
$bowtie2-build [options]* <reference_in> <bt2_index_base>

Plugging in the name of our files: we get the command $bowtie2-build culex_quinq_tRNArRNA.fa contam_align
 
To run alignment and put non-aligned reads into filtered fasta (?):
 
$bowtie2  --un M1_S4_L001_R1_001.cln.flt.fastq.gz -x contam_align -U M1_S4_L001_R1_001.cln.fastq.gz -b M1_S4_L001_R1_001.ctn.bam
-U means single end files

-b for output bed file

Results: no contaminants were found

## 10.17
To verify the results from bowtie, I will blast the tRNA sequences against the sequence reads: using the short reads from a single data file as reference sequences, and use the tRNA sequences as query sequences:

1. Convert the fastq file to a fasta file:

$cat M1_S4_L001_R1_001.cln.fastq | awk '{if(NR%4==1) {printf(">%s\n",substr($0,2));} 
else if(NR%4==2) print;}' > M1_S4_L001_R1_001.cln.fa


2. Since you want the sequence reads want to be the database, make a blast db of the new fasta file (i.e., the culex reads).

$srun --pty bash
$module load blast
$makeblastdb -dbtype nucl  -in M1_S4_L001_R1_001.cln.fa


3. Run blast with tRNA file as query sequence
$ blastn -query culex_quinq_tRNArRNA.fa \
-max_target_seqs 20 \
-max_hsps 1 \
-outfmt "6 qseqid sseqid pident evalue bitscore" \
-db  M1_S4_L001_R1_001.cln.fa \
-out M1_S4_L001_R1_001.cln.blast_output


Results of BLAST: several matches were found with high percent identities and low p-values.

## 10.18

Because the blast results showed several matches were found with high percent identities and low p-values, but bowtie 2 found 0 alignments, I will align our sequence reads against the whole cq mitochondrial genome:

Found that the same error: ![unnamed](https://user-images.githubusercontent.com/78465068/138136776-717da779-0fe4-4884-9ae7-a45db8b99cb4.png)

Therefore, I used the -S for a sam output file instead of -b for bam and got an output alignment file called M1_S4_L001_R1_001.ctn2.sam

Each bowtie alignment took ~20min to run

Convert sam to bam:
srun --pty bash 
module load samtools
samtools view -S -b M1_S4_L001_R1_001.ctn2.sam > M1_S4_L001_R1_001.ctn2.bam

Full results below:
samtools flagstat M1_S4_L001_R1_001.ctn2.bam

51097708 + 0 in total (QC-passed reads + QC-failed reads)
0 + 0 secondary
0 + 0 supplementary
0 + 0 duplicates
220589 + 0 mapped (0.43% : N/A)
0 + 0 paired in sequencing
0 + 0 read1
0 + 0 read2
0 + 0 properly paired (N/A : N/A)
0 + 0 with itself and mate mapped
0 + 0 singletons (N/A : N/A)
0 + 0 with mate mapped to a different chr
0 + 0 with mate mapped to a different chr (mapQ>=5)

gcloud compute scp cherries-controller:/home/zz220/RISE/clndata/M1_S4_L001_R1_001.ctn2.bam ./

wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/015/732/765/GCF_015732765.1_VPISU_Cqui_1.0_pri_paternal/GCF_015732765.1_VPISU_Cqui_1.0_pri_paternal_genomic.gff.gz

--un: to get the file with anything that aligned to contaminants filtered out:


Basically, we put all of our tRNA and rRNA sequences into a "contaminants" file and then made an index using bowtie2.

We were able to get 6 output files with all the sequences that did NOT align with our contanminants file i.e. files with sequences that were not tRNAs or rRNAs (presumably mostly miRNAs are left).


## 10.28

Previous experiments show that using bowtie2 to get a file with all the reads that are not aligned to the contaminants is a viable option. In addition to the tRNAs + small rRNA + large rRNA in mitochondrial genome which was obtained from this [link] (https://www.ncbi.nlm.nih.gov/nuccore/?term=Culex+quinquefasciatus+mitochondrion), the contaminant file also includes the 5S rRNA sequence. The contaminant file is called [culex_quinq_tRNArRNA.fa](https://github.com/AngelaZhou779/RISE/blob/main/miscellaneous/culex_quinq_tRNArRNA.fa)

Next, we will align our cleaned (trimmed) data files to our contaminant file:
1. Recreate index with modified contaminant file:
$bowtie2-build culex_quinq_tRNArRNA.fa contam_align

2. Create a slurm script for each data sample:
This is the slurm script for the first sample (M1) [here](https://github.com/AngelaZhou779/RISE/blob/main/miscellaneous/bowtie2slurmscriptM1.SBATCH)

Trying to grep for the tRNA sequence to check: >NC_014574.1:c1369-1304 Culex quinquefasciatus mitochondrion, complete genome

```
[zz220@cherries-controller newbowtiealignment]$ grep -c AACTTTATATTCAATAATGATATTAGACTGCAATTCTGAAGGAATAATTTTTTAATTATTAAAGTT P3_S3_L001_R1_001.cln.fastq
12
[zz220@cherries-controller newbowtiealignment]$ grep -c AACTTTATATTCAATAATGATATTAGACTGCAATTCTGAAGGAATAATTTTTTAATTATTAAAGTT P3.flt.cln.fq.gz
0
```

checking if this sequence from the contaminant file is still in the filtered files, it is not.

I also added the alignment rates into my small RNA files summary table (excel sheet).

Uploading the files without the contaminants, i.e. the filtered files onto the google bucket: gsutil cp *flt.cln.fq gs://gu-biology-pi-paa9/culexBiting_smallRNA/cleaned_reads/

AFTER ALL THE CLEANING AND FILTERING, the amount of reads that were left are detailed in this table:
https://github.com/AngelaZhou779/RISE/blob/main/miscellaneous/small%20RNA%20files%20summary%20table1.xlsx


## Nov 11

Downloaded miRDeep2 on my google HPC using the following [script](https://github.com/AngelaZhou779/RISE/blob/main/Conda_VirtualEnvironment.md): Sarah wrote the guide and I added comments as I installed it. 

Tried to update anaconda but got this error message:

```
Preparing transaction: done
Verifying transaction: failed

EnvironmentNotWritableError: The current user does not have write permissions to the target environment.
  environment location: /home/share/apps/python/anaconda3-3.8
  uid: 250823
  gid: 100
```
## Nov 14

Made two fasta files with miRNAs from the Hong et al paper and frmo miRBase named CulexpipiensmiRNAHong.fa and CulexquiqmiRBase.fa respectively.

## Nov 15

$ grep -v ">" CulexpipiensmiRNAHong.fa >cp_seqonly

$ grep -Ff cp_seqonly CulexquiqmiRBase.fa|more

Hong et. al has sone redundant sequences because it occurs multiple places within the genome. Moving foward we will work with the nonredundant entries. In addition, we applied size sorting of 18-24 base pairs.

In addition, it looks like miRBase offers both precursor and mature sequences, but the Hong et. al paper only offers mature sequences so from now on, we will go forward using the mature sequences. They will be compiled in this file

## Nov 26
mapper.pl- pre step to get arf file

miRDeep2 script

Get rid of redundancies in hong et al. 
get rid of redundanices btw both files
combine into one file called (unique)[https://github.com/AngelaZhou779/RISE/blob/main/miscellaneous/unique_miRNAs.fa]

However, please note that some sequences in the file are identical execpt due to size sorting, they are off by 1-3 base pairs.

We considered using ranfold p-value to determine potentially determine novel miRNAs that form stable hairpin structures:
ranfold p value: RNA fold from vienna suite- stable hairpin structure

Result: It looks like the ranfold p-value for all miRNAs *including the miRNAs that were on miRBase and from Hong et al. had a 0 ranfold p-value suggesting that ranfold p-value is not a good way to measure the potential stability of these small RNAs. Given that we already have quite a comprehensive list of miRNAs in cx. quiq and cx. pipiens. Therefore, we decided to proceeed forward without identifying novel miRNAs.

mapper: mature and precursor miRNA read files gives us quantification wihtout haivng to run the miRDeep2 script. 

## Dec 3
Result from miRDeep2, running mapper.pl: resulting cvs file with 16 columns. Upon looking through this cvs file, you see that some columns are repeated because 
1) The same miRNA but different precursors
2) Different miRNAs (from either Hong or miRBase) and we need to manually check the sequences to see if they are close (one base difference)

I collapsed the identical rows. I listed out the reason why I collapsed the rows and listed the repeated rows in this excel sheet: (repeated sequences)[https://github.com/AngelaZhou779/RISE/blob/main/miscellaneous/AfterMiRDEEP2_InprepforDESeq/Repeated%20sequences.xlsx]

I will be running DESeq with the following cvs file with the identical rows removed and with only the needed data columns (counts_miRNA.csv)[https://github.com/AngelaZhou779/RISE/blob/main/miscellaneous/input%20for%20DESeq/counts_miRNA.csv]

## Dec 8
Ran DESeq https://github.com/AngelaZhou779/RISE/blob/main/script/DESeqmiRNA.R

and obtained the following volcano plot with 8 DE miRNAs: ![updated volcano plot](https://user-images.githubusercontent.com/78465068/156470750-19dfb1c7-f96d-4605-9d33-5d2092fc29d1.png)
Figure 1. Volano plot showing the 8 DE miRNAs as 8 red dots. They have large fold changes that are also statistically significant. We used cutoff values of filter(padj < 0.05, abs(log2FoldChange) > 0.58) corresponding to a 1.5 fold change increase or decrease in expression.

I also obtained a table listing all the significant miRNAs with their corresponding p-value and log fold change.

## Jan-Feb 2021

Now that I have obtained the list of significant miRNAs, we have decided to go ahead to first:

1. Explore their biological functions through doing literature searches
2. Predict their downstream target messenger RNAs

Sarah will be spearheading point 2. Regarding point 1., we found an important supplementary table from Xu et. al. that listed all of the predicted and validated of mosquito miRNA targets and functions:

[miRNAs highlighted Table_S1_Development of miRNA-Based Approaches to Explore the Interruption of Mosquito-Borne Disease Transmission.docx](https://github.com/AngelaZhou779/RISE/files/8174654/miRNAs.highlighted.Table_S1_Development.of.miRNA-Based.Approaches.to.Explore.the.Interruption.of.Mosquito-Borne.Disease.Transmission.docx)

The table with the signifcant miRNAs and notes from Xu. et al. are here:
[miRNA notes.xlsx](https://github.com/AngelaZhou779/RISE/files/8174752/miRNA.notes.xlsx)

Link to my lab presentation with results and discussing the results: 

[Lab presentation 2.21 most updated version.pptx](https://github.com/AngelaZhou779/RISE/files/8174756/Lab.presentation.2.21.most.updated.version.pptx)

Overall, we found 3 main trends in biological function: 
1. Immunity
2. Longevity/Fertility
3. Energy utilization

Two of our significant miRNAs did not have any annotation in Xu et. al so I will proceed to do seperate literature searches for them:
miR-283 and miR-2592

https://www.ncbi.nlm.nih.gov/gene/100314356
https://pubmed.ncbi.nlm.nih.gov/20817720/
https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2956262/
https://www.ncbi.nlm.nih.gov/gene/100314356
https://journals.plos.org/plosntds/article?id=10.1371/journal.pntd.0006463
https://www.mdpi.com/1999-4915/13/8/1464

Future directions
Target identification of the 8 DE miRNAs
Discuss with collaborators
RT-PCR



