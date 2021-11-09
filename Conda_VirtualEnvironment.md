# Making a conda virtual environment to install miRDeep2 on the hpc
First go into computational node: srun --pty bash

Conda: https://uoa-eresearch.github.io/eresearch-cookbook/recipe/2014/11/20/conda/
- I don't think the "anaconda" part is really needed in the second line (can you specify only that you download anaconda?)

load anaconda:
```
module load anaconda3/3.8
conda create --name conda-env anaconda
```
Creating the environment took a long time (30 minutes?) and then it wanted me to agree with downloaded a bunch of packages (about 350MB)

To go into the conda environment I had to initialize the terminal (?) with `conda init bash` and then close out of the terminal and go back in. I was then able to activate the environment from my home directory with `conda activate conda-env`

To exit out of the conda environment you use `conda deactivate`


After I was in the environment, I then tried rerunning the code to install miRDeep2
```
conda install -c bioconda mirdeep2
```
Everything installed fine:
```
Proceed ([y]/n)? y


Downloading and Extracting Packages
viennarna-2.3.3      | 30.7 MB   | ##################################### | 100%
randfold-2.0.1       | 705 KB    | ##################################### | 100%
Preparing transaction: done
Verifying transaction: done
Executing transaction: done
```
I wasn't completely sure where things were but typing in the main script name `miRDeep2.pl` to the terminal while in the conda environment showed script usage instructions and the location at `/home/sm3679/.conda/envs/conda-env/bin/miRDeep2.pl`

The usage instruction have the helpful format of running at the end:
```
Example of use:

miRDeep2.pl reads.fa genome.fa reads_vs_genome.arf mautre_ref_miRNAs.fa mature_other_miRNAs.fa  hairpin_ref_miRNAs -t Mouse 2>report.log
```




To remove a conda environment: `conda remove -n yourenvname -all`



anaconda environemnet is hideen: ls -lah
environment is hidden, you know that because there is a . in front of the environment: .conda
