'''
Created on Feb 17, 2019

@author: pat
'''

dna_sequence = "ACTGATCGATTACGTATAGTATTTGCTATCATACATATATATCGATGCGTTCAT"

count_A = dna_sequence.count("A")
count_T = dna_sequence.count("T")
total_AT_count = count_A + count_T

print(str(total_AT_count / len(dna_sequence)))