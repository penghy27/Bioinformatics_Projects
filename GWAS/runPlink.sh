#!/usr/bin/env bash
# runPlink.sh
# Usage: bash runPlink.sh


# This script uses PLINK to perform a basic genome-wide association study (GWAS) using the example data.
# The example data must be downloaded and extracted first using the getExamples.sh script.

# Check the file is intact, and we get basic summary statistics from .map and .ped files
plink --file hapmap1

# see hapmap1.map results
# Each line of the MAP file describes a single marker nad must have following 4 columns:
# chromosome 1, rs#/snp, genetic distance, bp position
less hapmap1.map > hapmap1_map.txt

# see hapmap1.ped results
# The first six columns are mandatory: 
# Family ID, Individual ID, Paternal ID, Maternal ID, Sex(1=male, 2=female, other=unknown), phenotype
less hapmap1.ped > hapmap1_ped.txt

# See population phenotype file: pop.phe, which has 3 columns:
# Family ID, Individual ID, population (chinese:1, japnese: 2)
less pop.phe > pop_phe.txt

# See quantitative phenotype file: qt.phe, which has 3 columns:
# Family ID, Individual ID, continues number
less qt.phe > qt_phe.txt

# Making a binary PED file
plink --file hapmap1 --make-bed --out hapmap1

# see .bim file
# The format is similar with .map file. The columns as follows:
# Chromsome, variant identifier, position, bp coordinate, allele 1, allele 2
less hapmap1.bim > hapmap1_bim.txt

# Working with the binary PED file
plink --bfile hapmap1

# Summary statistics: missing rates
# --missing: shows missingness per individual and per marker
plink --bfile hapmap1 --missing --out miss_stat

# See missing results, indicates 6 columns as follows:
# Family ID, Individual ID, missing phenotyype, # SNP misses, #Genotype, proportion of individual missing 
less miss_stat.imiss > miss_stat_imiss.txt

# See missing locus. The 5 columns as follows:
# chromosome, SNP, #missing individuals, # genotype, proportion of individual missing
less miss_stat.lmiss > miss_stat_lmiss.txt

# Summary statistics: allele frequencies
plink --bfile hapmap1 --freq --out freq_stat

# See freq_stat.frq (--freq: Allele frequencies (founder only) 
# Chromosome, SNP, allele 1, allel 2, MAF(minor allele frequency), NCHROBS(# chromosome) 
less freq_stat.frq > freq_stat_frq.txt

# Performe the frequency analysis stratified by a categorial, cluster variable. Use --within option 
plink --bfile hapmap1 --freq --within pop.phe --out freq_stat

# See freq_stat.frq.strat
# The columns as follows:
# Chromosome, SNP, cluster, allele 1, allele2, MAF, MAC, #NCHROBS
less freq_stat.frq.strat > freq_stat_strat.txt

# If interested in a specific SNP, and want to know what the frequency was in two population. Use --snp option
plink --bfile hapmap1 --snp rs1891905 --freq --within pop.phe --out snp1_frq_stat

# Basic association analysis
plink --bfile hapmap1 --assoc --out as1

# See as1.assoc results, which shows columns as follows:
# chromosome, SNP, bp position, A1(minor frequency allele), F_A(frequence of affected phenotype), 
# F_U(frequency of unaffected phenotype), A2, CHISQ(chi-square test), P(p value), OR(odds ratio)
less as1.assoc > as1_assoc.txt

# In unix/linux environment, we can sort the result
# It shows the simulated disease variant rs2222162 is the second most significant SNP in the list.
sort --key=7 -nr as1.assoc | head > sort_as1_assoc.txt

# To get a sorted list of association results, that also includes a range of significance values for multiple testing 
# use the --adjust flag
plink --bfile hapmap1 --assoc --adjust --out as2

# see as2.assoc.adjusted results. The fileds as follows:
# Chromosome, SNP, unadjusted, genomic control, Bonferroni value, Holm step-down value,
# Sidak single-step value, Sidak step-down value, FDR control(BH), FDR control(BY)
less as2.assoc.adjusted > as2_assoc_adjusted.txt

# Look at the inflation factor that result from phenotype in case/control analysis
plink --bfile hapmap1 --pheno pop.phe --assoc --adjust --out as3

# Stratification analysis
# --cluster: requests IBS clustering; --mc 2: constraint each cluster has no more than 2 individuals
# --ppc 0.05: Merge distance p-value constraint = 0.05
plink --bfile hapmap1 --cluster --mc 2 --ppc 0.05 --out str1

# Association analysis, accounting for clusters
plink --bfile hapmap1 --mh --within str1.cluster2 --adjust --out aac1

# Quantitative trait association analysis
plink --bfile hapmap1 --assoc --pheno qt.phe --out quant1

# Print a message indicating that the GWAS is complete
echo "GWAS analysis complete."


 










 

























