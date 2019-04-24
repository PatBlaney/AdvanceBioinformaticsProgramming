'''
Created on Feb 21, 2019

@author: pat
'''

dna_section_file = open('genomic_dna.txt')
dna_section = dna_section_file.read()
exon_index_file = open('exons.txt')
exon_output = open('exon_output.txt', 'w')
all_exons = ""

for line in exon_index_file:
    exon_index_list = line.split(',')
    exon_start = int(exon_index_list[0])
    exon_end = int(exon_index_list[1])
    exon = dna_section[exon_start:exon_end]
    all_exons = all_exons + exon
dna_section_file.close()
exon_index_file.close()

exon_output.write(all_exons)
