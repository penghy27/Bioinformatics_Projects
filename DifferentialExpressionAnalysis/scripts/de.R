#!/usr/bin/env Rscript
# de.R
library(tximport)
library(readr)
library(DESeq2)
library(knitr)

# TODO: update constants for your machine
# Define constants
TESTING <- FALSE # Change to FALSE if using entire Samples set
RESULTS_DIR <- "/home/peng.hsi/BINF6309/module04-penghy27/results"
AIPTASIA_DIR <- "/work/courses/BINF6309/AiptasiaMiSeq"

# for testing purposes - alternative samples table
testing_samples <- data.frame(Sample = c("Aip02", "Aip02", "Aip02", "Aip02"),
                              Menthol = c("Control", "Control", "Menthol", "Menthol"),
                              Vibrio = c("Control", "Vibrio", "Control", "Vibrio"))
head(testing_samples)

# True script begins
tx2gene <- read.csv(file.path(RESULTS_DIR, "tx2gene.csv"))
head(tx2gene)

if (TESTING) {
  print("***Running test with Aip02 only***")
  samples <- testing_samples
} else {
  samples <- read.csv(file.path(AIPTASIA_DIR, "Samples.csv"), header=TRUE)
}
head(samples)


files <- file.path(RESULTS_DIR, "quant", samples$Sample, "quant.sf")
txi <- tximport(files, type="salmon", tx2gene=tx2gene)

dds <- DESeqDataSetFromTximport(txi, colData = samples, 
                                design = ~ Menthol + Vibrio)

dds$Vibrio <- relevel(dds$Vibrio, ref = "Control")
dds$Menthol <- relevel(dds$Menthol, ref = "Control")
keep <- rowSums(counts(dds)) >= 10
dds <- dds[keep,]
dds <- DESeq(dds)

padj <- .05
minLog2FoldChange <- .5
dfAll <- data.frame()
# Get all DE results except Intercept, and "flatten" into a single file.
for (result in resultsNames(dds)){
  if(result != 'Intercept'){
    res <- results(dds, alpha=.05, name=result)
    dfRes <- as.data.frame(res)
    dfRes <- subset(subset(dfRes, select=c(log2FoldChange, padj)))
    dfRes$Factor <- result
    dfRes <- subset(dfRes, padj < 0.05)
    dfAll <- rbind(dfAll, dfRes)
  }
}
head(dfAll)

write.csv(dfAll, file=file.path(RESULTS_DIR, "dfAll.csv"))
# end of de.R script

# TODO: update file to filter for adjusted p-value (padj < 0.05) 
# AND merge pathways and pathway names (use your tables from Annotation)
# with the results, writing them to deAnnotated.csv

# Load BLAST results & dfAll.csv as a table
path <- "/work/courses/BINF6309/data_BINF6309/Module4/Annotation/path.txt"
pathdescription <- "/work/courses/BINF6309/data_BINF6309/Module4/Annotation/ko"
dfAllfile <- "/home/peng.hsi/BINF6309/module04-penghy27/results/dfAll.csv"

pathway <- read.table(path, sep="\t", header=FALSE)
pathdes <- read.table(pathdescription, sep="\t", header = FALSE)
df <- read.csv(dfAllfile, header = TRUE)

# Set column names to match fields selected in BLAST
colnames(pathway) <- c("ko", "path") 
colnames(pathdes) <-c("path", "description")
colnames(df) <- c("ko", "log2FoldChange", "padj", "Factor")

# Check the pathway & description table
#kable(head(pathway))
#kable(head(pathdes))
#kable(head(df))

# merge two tables: pathway & path description
kopathdes <- merge(pathway, pathdes)

# check the merge table
kable(head(kopathdes))

merged_df <- merge(df, kopathdes, by = "ko")
kable(head(merged_df))

# Reorder columns
df_new <- merged_df[c("ko", "path", "description", "log2FoldChange", "padj", "Factor")]

# Merge with kopathdes
merged <- merge(df_new, kopathdes)

# Check column order
kable(head(merged))

# Define output directory
OUTDIR <- "/home/peng.hsi/BINF6309/module04-penghy27/results"
# Write to CSV file
write.csv(merged, file = file.path(OUTDIR, "deAnnotated.csv"), row.names = FALSE)

