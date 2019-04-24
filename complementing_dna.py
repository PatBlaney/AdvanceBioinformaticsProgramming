'''
Created on Feb 17, 2019

@author: pat
'''

dna_sequence = "ACTGATCGATTACGTATAGTATTTGCTATCATACATATATATCGATGCGTTCAT"

complement_mapping = dna_sequence.maketrans("ATGC", "TACG")
dna_complement = dna_sequence.translate(complement_mapping)
print(dna_complement)