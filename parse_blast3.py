'''
Created on Apr 2, 2019
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

transcript_to_swissprot = {}
for line in blast_file:
    (transcript_id, swissprot_id) = blast_parser(line)
    transcript_to_swissprot[transcript_id] = swissprot_id

output_file = open('parse_blast3_output.txt', 'w')
diff_exp_file = open('/scratch/RNASeq/diffExpr.P1e-3_C2.matrix')
diff_exp_header = diff_exp_file.readline()
diff_exp_lines = diff_exp_file.readlines()

def diff_exp_parser(diff_exp_line):
    diff_exp_attributes = diff_exp_line.split('\t')
    transcript_id = diff_exp_attributes[0]
    sp_ds = diff_exp_attributes[1]
    sp_hs = diff_exp_attributes[2]
    sp_log = diff_exp_attributes[3]
    sp_plat = diff_exp_attributes[4]
    diff_exp_info = (
        transcript_to_swissprot.get(transcript_id, transcript_id), 
        sp_ds,
        sp_hs,
        sp_log,
        sp_plat)
    return diff_exp_info
    
diff_exp_info = list(map(diff_exp_parser, diff_exp_lines))

def output_writer(diff_exp_tuple):
    transcript_id = diff_exp_tuple[0]
    sp_ds = diff_exp_tuple[1]
    sp_hs = diff_exp_tuple[2]
    sp_log = diff_exp_tuple[3]
    sp_plat = diff_exp_tuple[4]
    output_file.write('\t'.join([transcript_id, sp_ds, sp_hs, sp_log, sp_plat]))

list(map(output_writer, diff_exp_info))

blast_file.close()
output_file.close()
diff_exp_file.close()
