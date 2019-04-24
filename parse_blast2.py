'''
Created on Mar 4, 2019
@author: pat

Read in BLAST and differential gene expression files, parse the BLAST file to store all 
transcript IDs and associated SwissProt IDs, parse differential gene expression file
to write the data along with the SwissProt ID to an output file.
'''
import re

blast_file = open('/scratch/RNASeq/blastp.outfmt6')
def blast_parser(blast_line):
    blast_attributes = blast_line.split('\t')
    transcript_id = re.match(r'\w+', blast_attributes[0])
    swissprot_id = re.search(r'(\w{6})\.', blast_attributes[1])
    return transcript_id.group(), swissprot_id.group(1)

assert blast_parser('c100_g1_i1|m.108\tgi|74582957|sp|O94654.1|YGF3_SCHPO\t100') == ('c100_g1_i1', 'O94654')

transcript_to_swissprot = {}
for line in blast_file:
    (transcript_id, swissprot_id) = blast_parser(line)
    transcript_to_swissprot[transcript_id] = swissprot_id

output_file = open('parse_blast2_output.txt', 'w')
diff_exp_file = open('/scratch/RNASeq/diffExpr.P1e-3_C2.matrix')
diff_exp_file.readline()
for line in diff_exp_file:
    diff_exp_attributes = line.split('\t')
    diff_exp_data = '\t'.join(diff_exp_attributes[1:])
    transcript_id = diff_exp_attributes[0]
    if transcript_id in transcript_to_swissprot:
        output_file.write('\t'.join([transcript_to_swissprot[transcript_id], diff_exp_data]))
    else:
        output_file.write('\t'.join([diff_exp_attributes[0], diff_exp_data]))
        
blast_file.close()
diff_exp_file.close()