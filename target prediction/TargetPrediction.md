We are in the process of finalizing software (starting with RNAhybrid) but we also need to have 3'UTRs for whatever software we use to help predict targets of the differentially expressed miRNAs. Since we do not paritcularly want to do UTR prediction on the newest reference genome from NCBI (or else try to annotate the UTR by identifying the mRNA regions that are adjacent to exons), we will use the an older version of the Culex quinquefasciatus genome from vectorbase which already has UTR annotations. We think this is enough since the regions close to genes (UTRs) are likely similar between the older and newer reference genomes. 

# Using UTRs from old vectorbase genome
We decided to use the 3'UTR from vectorbase based on the older reference genome and annotations (Johannesburg)
```
wget https://vectorbase.org/common/downloads/Current_Release/CquinquefasciatusJohannesburg/fasta/data/VectorBase-55_CquinquefasciatusJohannesburg_Genome.fasta

wget https://vectorbase.org/common/downloads/Current_Release/CquinquefasciatusJohannesburg/gff/data/VectorBase-55_CquinquefasciatusJohannesburg.gff
```

## Parse out the UTR regions from gff file and get fasta specific to those UTR
Put all the annotated 3'UTR into a UTR-specific gff
```
grep "three_prime_UTR" VectorBase-55_CquinquefasciatusJohannesburg.gff > three_prime_UTR.gff
```

Convert the gff file into a bed file. I already have bedops downloaded from a previous project (https://bedops.readthedocs.io/en/latest/content/reference/file-management/conversion/gff2bed.html)

In order to run this you must set the path to find it (I did this from $HOME) `export PATH=$PATH:$PWD/bin/bedops/bin`

```
/home/sm3679/bin/bedops/bin/gff2bed < /home/sm3679/culex_smallRNA/culexJ_genome/three_prime_UTR.gff > /home/sm3679/culex_smallRNA/culexJ_genome/three_prime_UTR.bed
```

Run [bedtools_getfasta](https://github.com/AngelaZhou779/RISE/blob/main/target%20prediction/bedtools_getfasta.sh) with the new bed file and complete fasta
