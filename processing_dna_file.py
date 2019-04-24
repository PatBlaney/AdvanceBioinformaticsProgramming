'''
Created on Feb 21, 2019

@author: pat
'''

dna_file = open('input.txt')
output_file = open('output.txt', 'w')

for seq in dna_file:
    trimmed_seq = seq[14:]
    output_file.write(trimmed_seq)
    print(len(trimmed_seq))

dna_file.close()