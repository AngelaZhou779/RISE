# This script runs DESeq2 (specifically starting with a count matrix file)

##Install DESeq2
# if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
# BiocManager::install("DESeq2")
# BiocManager::install('EnhancedVolcano')



#Load Libraries
library(DESeq2); library(ggplot2); library(EnhancedVolcano); library(tidyverse)


# Set working directory to source file location

# Read in the count data matrix
countData <- read.csv('counts_miRNA.csv', header = TRUE)
head(countData)

#Create the metaData table (this could alternatively be made externally and read in)
sampleNames <- colnames(countData)[2:7] #Here I am calling the column names of the Count matrix, minus the first column which is the name for the miRNA annotations
sampleConditions <- substr(sampleNames, 2, 2) #to get conditions I'm pulling the second letter from the sample names, which is either m (molestus, non-biting) or p (pipiens, biting)

metaData <- data.frame(sampleName = sampleNames,
                       condition = sampleConditions)
str(metaData)
metaData$condition <- factor(metaData$condition)

# Make the DESeq dataset
dds <- DESeqDataSetFromMatrix(countData = countData, 
                              colData = metaData, 
                              design= ~ condition, tidy = TRUE)
dds


#getting rid of rows with less than 10 reads 
#DESeq recommends a pre-filtering step to reduce memory size and increase speed. They suggest keeping only rows which have 10 reads total

keep <- rowSums(counts(dds)) >= 10
dds <- dds[keep,]

#checking on the dataset
dds

# class: DESeqDataSet 
# dim: 90 6 
# metadata(1): version
# assays(1): counts
# rownames(90): cqu-bantam-5p_MIMAT0014420 cqu-bantam-3p_MIMAT0014421 ... cqu-miR-9-3p_MIMAT0014381
# cqu-miR-9-5p_MIMAT0014380
# rowData names(0):
#   colnames(6): cm1 cm2 ... cp2 cp3
# colData names(2): sampleName condition

#Relevel the condition for what to compare to. Likely not important in our case with two conditions, but you would want everything compared to the control. (Default is first condition alphabetically, in this case, maybe we can set it up to nonbiting?)
dds$condition <- relevel(dds$condition, ref = "m")

# A bit of quality control
# Look at the distribution of the count data across the samples, will make a boxplot, check to see if the sizes are comparable across samples. Stats things to make sure our data looks normal. can export and save as image
# PCA longest axis, explains most variation of the data and seperates it based on that
librarySizes <- colSums(counts(dds))

#saved image as "barplot of library sizes"; it gives you an iea of count distribution across samples
barplot(librarySizes, 
        names=names(librarySizes), 
        las=2, ylim = c(0,1.6e+07),
        main="Barplot of library sizes")

logcounts <- log2(counts(dds) + 1)
head(logcounts)
