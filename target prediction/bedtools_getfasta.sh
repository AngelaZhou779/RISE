#!/bin/bash
#SBATCH --job-name=bedtools_getfasta --output=%x.%j.out
#SBATCH --mail-type=END,FAIL --mail-user=sm3679@georgetown.edu
#SBATCH --nodes=1 --ntasks=1 --cpus-per-task=1 --time=72:00:00
#SBATCH --mem=4G


#-----------------------------------------------------------------------------#

# This script runs bedtools getfasta to pull sequence from full assembly   #

#-----------------------------------------------------------------------------#

module load bedtools

#- RUN bedtools getfasta----------------------------------------------------------------#

bedtools getfasta \
-fo /home/sm3679/culex_smallRNA/culexJ_genome/three_prime_UTR.fasta \
-fi /home/sm3679/culex_smallRNA/culexJ_genome/VectorBase-55_CquinquefasciatusJohannesburg_Genome.fasta \
-bed /home/sm3679/culex_smallRNA/culexJ_genome/three_prime_UTR.bed \
-name #use the name field as a header for the UTR fasta (instead of "chromosome")

#- FIN -----------------------------------------------------------------------#
