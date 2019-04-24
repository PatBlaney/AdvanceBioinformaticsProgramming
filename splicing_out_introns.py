'''
Created on Feb 17, 2019

@author: pat
'''

dna_section = "ATCGATCGATCGATCGACTGACTAGTCATAGCTATGCATGTAGCTACTCGATCGATCGATCGATCGATCGATCGATCGATCGATCATGCTATCATCGATCGATATCGATGCATCGACTACTAT"

exon_1 = dna_section[:64]
exon_2 = dna_section[91:]
print("The coding regions of the DNA seciton are\nExon 1: %s\nExon 2: %s" % (exon_1, exon_2))

coding_percentage = (len(exon_1) + len(exon_2)) / len(dna_section) * 100
print("The percentage of the DNA section that is coding: %f" % coding_percentage)

intron = dna_section[65:91]
print(exon_1.upper() + intron.lower() + exon_2.upper())