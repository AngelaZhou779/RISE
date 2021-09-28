#!/bin/bash
#SBATCH --job-name=clnM1S4 --output=z01.%x
#SBATCH --mail-type=END,FAIL --mail-user=zz220@georgetown.edu
#SBATCH --nodes=1 --ntasks=1 --cpus-per-task=1 --time=72:00:00
#SBATCH --mem=4G

# --------------------------------------------------------------------#
# This script runs trimmomatic, output file go in working directory  #
#---------------------------------------------------------------------#

#- DEFINE FILE LOCATIONS--------------------------------------------#

trim_prog=/home/zz220/trimmomatic/Trimmomatic-0.39/trimmomatic-0.39.jar

input=/home/zz220/RISE/M1_S4_L001_R1_001.fastq.gz

output=/home/zz220/RISE/M1_S4_L001_R1_001.cln.fastq.gz

#- RUN command ----------------#
java -jar trimmomatic-0.39.jar SE \
$input \
$output \
ILLUMINACLIP:smRNA_NexFlex_adapters.fa:2:30:10
HEADCROP:10 \
TRAILING:10 \
SLIDINGWINDOW:4:15 \
MINLEN:17
#- FIN -----------------------#
