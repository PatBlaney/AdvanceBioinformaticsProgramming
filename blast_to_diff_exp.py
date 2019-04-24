'''
Created on Apr 10, 2019

@author: pat

Read in BLAST and differential gene expression files, parse the BLAST file to store all 
transcript IDs and associated SwissProt IDs, parse differential gene expression file
to write the data along with the SwissProt ID to an output file.
'''

class Blast(object):
    
    def __init__(self, blast_record):
        '''Parse BLAST file to construct Blast object'''
        query_info, swissprot_info, pident, *other_fields= blast_record.split('\t')
        self.transcript_id = query_info.split('|')[0]
        self.swissprot_id, swissprot_version = swissprot_info.split('|')[3].split('.')
        self.identity = float(pident)

class Matrix(object):
    
    def __init__(self, matrix_record):
        '''Parse differential expression data file to construct Matrix object'''
        diff_exp_attributes = matrix_record.split('\t')
        self.transcript = diff_exp_attributes[0]
        self.diauxic_shift = diff_exp_attributes[1]
        self.heat_shock = diff_exp_attributes[2]
        self.logarithmic_growth = diff_exp_attributes[3]
        self.plateau_phase = diff_exp_attributes[4]

def high_identity_filter(blast_obj):
    '''Filter to only BLAST matches with identity higher than 95'''
    return blast_obj.identity > 95.00

def output_writer(diff_exp_tuple):
    '''Accept differential expression tuple and return as tab-separated string'''
    transcript_id = diff_exp_tuple[0]
    diauxic_shift = diff_exp_tuple[1]
    heat_shock = diff_exp_tuple[2]
    logarithmic_growth = diff_exp_tuple[3]
    plateau_phase = diff_exp_tuple[4]
    return '\t'.join([transcript_id,
                      diauxic_shift,
                      heat_shock,
                      logarithmic_growth,
                      plateau_phase])

# Open BLAST file and parse high identity matches into Blast objects for a dictionary
blast_file = open('/scratch/RNASeq/blastp.outfmt6')
blast_list = blast_file.readlines()
blast_obj_list = list(map(Blast, blast_list))
high_identity_blast_dict = {blast_obj.transcript_id:blast_obj.swissprot_id
                            for blast_obj in blast_obj_list
                            if high_identity_filter}

# Open differential expression file and parse each row into Matrix object
# Print differential expression information to output file
output_file = open('blast_to_diff_exp_output.txt', 'w')
diff_exp_file = open('/scratch/RNASeq/diffExpr.P1e-3_C2.matrix')
diff_exp_header = diff_exp_file.readline()
diff_exp_list = diff_exp_file.readlines()
diff_exp_obj_list = list(map(Matrix, diff_exp_list))
for diff_exp_obj in diff_exp_obj_list:
    diff_exp_info = (
        high_identity_blast_dict.get(diff_exp_obj.transcript, diff_exp_obj.transcript), 
        diff_exp_obj.diauxic_shift,
        diff_exp_obj.heat_shock,
        diff_exp_obj.logarithmic_growth,
        diff_exp_obj.plateau_phase)
    diff_exp_output = output_writer(diff_exp_info)
    output_file.write(diff_exp_output)

blast_file.close()
output_file.close()
diff_exp_file.close()
