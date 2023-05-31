# -*- coding: utf-8 -*-
"""
Created on Tue Dec 27 11:45:25 2022
Filter seq by length
@author: Mor Hava Pereg
#command line : python Filter_by_Length.py input_fastq_file.fastq sample_name length_threshold output_path
"""
from sys import argv
from Bio import SeqIO
import os

#get fastq file 
my_file = open(argv[1], "r")

#length threshold
length_threshold = int(argv[3])

#filter seq by length
seq_num = 0
length_sequences = []  # Setup an empty list
for record in SeqIO.parse(my_file, "fastq"):
    seq_num = seq_num+1
    if len(record.seq) > length_threshold:
        # Add this record to our list
        length_sequences.append(record)

#print filter detail
#print("  ")
#print("____________Process - Filter by Length______________")
print("Sequences : %i" % seq_num)
print("Length threshold = %i" % length_threshold)
print("Sequences pass : %i" % len(length_sequences))


#change output dir
os.chdir(argv[4])
print("output directory: {0}".format(argv[4]))
#print("Filter by length - process DONE ")
#print("  ")

#output file 
s1 = argv[2] #sample name
s2 = "length-pass.fastq"
outname = "%s_%s" % (s1, s2)
SeqIO.write(length_sequences, outname, "fastq")