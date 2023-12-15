#!/usr/bin/env bash
# alignAll.sh
outDir='quant/'
#sample='Aip02' # TODO: update to loop over all Aip## samples

# initialize variable to contain the directory
fastqPath="/work/courses/BINF6309/AiptasiaMiSeq/fastq/"

# initialize varialbe to contain the suffix for both reads
leftSuffix=".R1.fastq"
rightSuffix=".R2.fastq"
prefix="Aip"

# loop over all files and align them
function align {
    # loop through all the left-read fastq files in $fastqPath
    for leftInFile in $fastqPath$prefix*$leftSuffix
    do
        # Remove the path from the filename
        pathRemoved="${leftInFile/$fastqPath/}"
        # Remove the left-read suffix from $pathRemoved
        sample="${pathRemoved/$leftSuffix/}"
        salmon quant -l IU \
            -1 $fastqPath$sample$leftSuffix \
            -2 $fastqPath$sample$rightSuffix \
            -i AipIndex \
            --validateMappings \
            -o ${outDir}${sample}
    done
}

align

