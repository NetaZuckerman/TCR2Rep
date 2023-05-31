# -*- coding: utf-8 -*-
"""
Created on Tue Dec 28 11:45:25 2022
Filter seq by length
@author: Mor Hava Pereg
#command line : python Filter_by_Quality.py input_fastq_file.fastq sample_name quality_threshold output_path
"""
from sys import argv
from Bio import SeqIO
import math
import os

#get fastq file 
my_file = open(argv[1], "r")

#quality threshold
quality_threshold = int(argv[3])

#converting integer Q scores to error probabilities
qual_to_prob = tuple(10 ** (-qual / 10) for qual in range(128))

#filter seq by quality
seq_num = 0 # for calculate seq number
quality_sequences = []  # Setup an empty list
#for each seq calculate quality by mapping of Phred score (index) to probability values 
for record in SeqIO.parse(my_file, "fastq"):
    qual_sum = 0.0
    for q in record.letter_annotations["phred_quality"]:
        qual_sum += qual_to_prob[q]

    p = qual_sum / len(record.letter_annotations["phred_quality"])
    q=math.floor(-10 * math.log10(p))

    seq_num = seq_num+1
    #save just seq above quality_threshold
    if q >= quality_threshold:
        # Add this record to our list
        quality_sequences.append(record)

#print filter detail
#print("  ")
#print("____________Process - Filter by Quality______________")
print("Sequences : %i" % seq_num)
print("quality threshold = %i" % quality_threshold)
print("Sequences pass : %i" % len(quality_sequences))


#change output dir
os.chdir(argv[4])
print("output directory: {0}".format(argv[4]))
#print("Filter by quality - process DONE ")
#print("  ")

#output file
s1 = argv[2] #sample name
s2 = "quality-pass.fastq"
outname = "%s_%s" % (s1, s2)
SeqIO.write(quality_sequences, outname, "fastq")




    

