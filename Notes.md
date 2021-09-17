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

Bring the html files back to local to veiw in web format (run command from local)
```
Cottonelles-MBP:~ cottonellezhou$ gcloud compute scp cherries-controller:/home/zz220/RISE/fastqc_out/*_fastqc.html .
```
