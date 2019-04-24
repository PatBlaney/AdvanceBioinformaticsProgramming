'''
Created on Feb 17, 2019

@author: pat
'''

dna_sequence = "ACTGATCGATTACGTATAGTAGAATTCTATCATACATATATATCGATGCGTTCAT"

EcoRI_cut_site = dna_sequence.find("GAATTC") + 1
dna_sequence_fragment_1 = dna_sequence[:EcoRI_cut_site]
dna_sequence_fragment_2 = dna_sequence[EcoRI_cut_site:]
print("Length of fragment 1 is %d" % len(dna_sequence_fragment_1))
print("Length of fragment 2 is %d" % len(dna_sequence_fragment_2))