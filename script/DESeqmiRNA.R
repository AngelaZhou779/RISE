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

#Is there any difference between per gene (miRNA??) counts for each of the sample groups?
statusCol <- as.numeric(factor(dds$condition)) + 1  # make a colour vector

#difference between per miRNA counts for each of the sample groups
#saved image as logcounts
boxplot(logcounts, 
        xlab="", 
        ylab="Log2(Counts)",
        las=2,
        col=statusCol)

#Adding median log counts
abline(h=median(as.matrix(logcounts)), col="blue")

#Looking at PCA of the data - Do treatments cluster together?
rlogcounts <- rlog(counts(dds)) #transforming data to make it approximately homoskedastic, n < 30 so rlog is better

data_for_PCA <- t(rlogcounts)
dim(data_for_PCA)

#run PCA
pcDat <- prcomp(data_for_PCA, center = T)
pcDat_df <- data.frame('Condition' = dds$condition, pcDat$x[,1:2])

# basic plot
ggplot(pcDat_df, aes(x = PC1, y = PC2, col = Condition)) +
  geom_point() + 
  theme_bw()

# Transform normalized counts using the rlog function ("RNASEQ20_Day3_HandsOn.pdf")
# see what percentage of the variance can be explained by PC1 (M v P i.e. nonbiting v biting)
#saved image as PCA counts
rld <- rlog(dds, blind=TRUE)
plotPCA(rld, intgroup="condition")

# Hierarchial Clustering
### Extract the rlog matrix from the object
# Heat map: look out for a row or block that are either all red or all blue
rld_mat <- assay(rld) #retrieve matrix from the rld object
# compute pairwise correlation values for samples
rld_cor <- cor(rld_mat)
# plot the correlation c=values as a heatmap
heatmap(rld_cor)



#now we move onto the DESeq analysis
# # Look at the difference in total reads from the different samples
# dds <- estimateSizeFactors(dds)
# 
# # Estimate the dispersion (or variation) or the data
# dds <- estimateDispersions(dds)
# 
# plotDispEsts(dds)

# Differential Expression Analysis
#Run DESeq
dds <- DESeq(dds)
res <- results(dds)
res

# Apparently, it is common to shrink the log fold change estimate for better visualization and ranking of miRNAs. Often, lowly expressed miRNAs tend to have relatively high levels of variability so shrinking can reduce this.
resultsNames(dds)
res_LFC <- lfcShrink(dds, coef="condition_p_vs_m", type="apeglm")
res_LFC

# Order the table by smallest p value
resOrdered <- res[order(res$pvalue),]
summary(res)

# out of 90 with nonzero total read count
# adjusted p-value < 0.1
# LFC > 0 (up)       : 7, 7.8%
# LFC < 0 (down)     : 9, 10%
# outliers [1]       : 0, 0%
# low counts [2]     : 0, 0%
# (mean count < 70)
# [1] see 'cooksCutoff' argument of ?results
# [2] see 'independentFiltering' argument of ?results

#Basic MA-plot
plotMA(res, ylim=c(-3,3))
plotMA(res_LFC, ylim=c(-3,3)) # See an even amou

#If you want to interactivly find miRNAs associated with certain points
# idx <- identify(res$baseMean, res$log2FoldChange)
# rownames(res)[idx]

# Volcano plot of the lfcShrink data. For various setting try: `browseVignettes("EnhancedVolcano")`
EnhancedVolcano(res_LFC,
                lab = rownames(res_LFC),
                x = 'log2FoldChange',
                y = 'padj',
                selectLab = NA,
                #drawConnectors = TRUE,
                xlim = c(-5, 5),
                ylim = c(0,15),
                pCutoff = 10e-5,
                FCcutoff = 0.58,
                pointSize = 2.0,
                labSize = 5.0)
# Can look at which of the result are significant and have a high enough log2 fold change
sig_res <- res_LFC %>%
  data.frame() %>%
  rownames_to_column(var="miRNA") %>% 
  as.data.frame() %>% 
  filter(padj < 0.05, abs(log2FoldChange) > 0.58)

# Write out a table of these significant differentially abundant miRNAs
write.csv(select(sig_res, miRNA, log2FoldChange, padj), 
          file="pvm_LFCshrink_padj.txt", col.names = F, row.names = F)

# Write out just the miRNA names for later analysis in KEGG
write.table(sig_res %>% select(miRNA), 
            file="NB_LDvSD_test.txt", col.names = F, row.names = F, quote = F)

