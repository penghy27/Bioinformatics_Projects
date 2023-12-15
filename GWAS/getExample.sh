#!usr/bin/env bash
# getExample.sh


# This script will download the example data from the PLINK website and extract it to the GWAS directory.

# Define the URL for the example data
example_data=https://zzz.bwh.harvard.edu/plink/hapmap1.zip

# Define the directory path to where the example data will be downloaded and extracted
gwas_dir="GWAS/"

# Change the directory to the GWAS directory
cd $gwas_dir

# Download the example data using wget
wget $example_data

# Extract the example data using unzip
unzip hapmap1.zip

# Remove the downloaded zip file to save disk space
rm hapmap1.zip

# Print a message indicating that the example data has been downloaded and extracted
echo "Example data downloaded and extracted to $gwas_dir."

