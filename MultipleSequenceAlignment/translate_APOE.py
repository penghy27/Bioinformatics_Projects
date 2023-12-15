#!/usr/bin/env python3
# translate_APOE.py

from Bio import SeqIO
from Bio.Seq import Seq

# Read in the APOE reference transcript fasta file
records = SeqIO.parse("APOE_refseq_transcript.fasta", "fasta")

# Open a new file for writing the translated sequences
out_file = open("apoe_aa.fasta", "w")

# Iterate over the records and translate each sequence
for record in records:
    # Use the DNA alphabet to translate the sequence to amino acids
    aa_sequence = Seq(str(record.seq)).translate()
    
    # Write the translated sequence to the output file
    out_file.write(">{}\n{}\n".format(record.description, aa_sequence))

# Close the output file
out_file.close()

