#!/bin/bash
#SBATCH --job-name=fastqc --output=%x.%j.out
#SBATCH --mail-type=END,FAIL --mail-user=zz220@georgetown.edu
#SBATCH --nodes=1 --ntasks=1 --cpus-per-task=1 --time=72:00:00
#SBATCH --mem=4G

#-----------------------------------------------------------------------------#
# This script gives quality control of fastq files #
#-----------------------------------------------------------------------------#

#- RUN fastqc ----------------------------------------------------------------#

/home/zz220/FastQC/fastqc -o /home/zz220/RISE/fastqc_out /home/zz220/RISE/*fastq.gz

#- FIN -----------------------------------------------------------------------#
