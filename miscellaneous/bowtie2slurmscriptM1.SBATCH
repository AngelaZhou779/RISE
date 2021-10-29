#!/bin/bash
#SBATCH --job-name=Alignment_sbatch --output=z01.%x
#SBATCH --mail-type=END,FAIL --mail-user=zz220@georgetown.edu
#SBATCH --nodes=1 --ntasks=1 --cpus-per-task=1 --time=72:00:00
#SBATCH --mem=8G
 
#-----------------------------------------------------------------------------#
# This is a Slurm script running bowtie2 for M1 files#
#---------------------------------------------------------------------#
 
#- Load Module--------------------------------------------#
module load bowtie2/2.4.4
 
#- DEFINE FILE LOCATIONS--------------------------------------------#
 
index_base=contam_align
 
#- RUN command ----------------#
bowtie2  --un M1.flt.cln.fq.gz -x $index_base -U M1_S4_L001_R1_001.cln.fastq.gz -S M1.flt.cln.sam

#- Unload module----------------#
module unload bowtie2/2.4.4

#- FIN -----------------------#


