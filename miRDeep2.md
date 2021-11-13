## miRDeep2 notes
Identification of novel and known miRNAs in deep sequencing data
miRNA expression profiling across samples
Last, a new module for preprocessing of raw Illumina sequencing data produces files for downstream analysis with the miRDeep2 or quantifier module. 

defining coordinates of where miRNAs are so it only has to map to subset of genome, and then quanitifcation in second step:
Preprocessing is performed with the mapper.pl script:
fasta file with deep sequencing reads, a fasta file of the corresponding genome, a file of mapped reads to the genome in miRDeep2 arf format
to produce what is miRDeep2 arf format?

Quantification and expression profiling is done by the quantifier.pl script. miRNA identification is done by the miRDeep2.pl script.

scipt: enter conda environment
![image](https://user-images.githubusercontent.com/78465068/140952141-79a819b6-5621-47e1-b199-81dee8ebd085.png)

