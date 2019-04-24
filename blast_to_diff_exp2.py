'''
Created on Apr 12, 2019
@author: pat

Read in user-defined BLAST and differential gene expression files, 
parse the BLAST file to store all transcript IDs and associated 
SwissProt IDs, parse differential gene expression file
to write the data along with the SwissProt ID to an output file.
Write any error messages to error file.
'''
import sys
import re

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
        if len(diff_exp_attributes) == 5 and re.search("\w{7}", diff_exp_attributes[0]):    
            self.transcript = diff_exp_attributes[0]
            self.diauxic_shift = diff_exp_attributes[1]
            self.heat_shock = diff_exp_attributes[2]
            self.logarithmic_growth = diff_exp_attributes[3]
            self.plateau_phase = diff_exp_attributes[4]
        else:
            raise ValueError

def high_identity_filter(blast_obj):
    '''Filter to only BLAST matches with identity higher than 95'''
    return blast_obj.identity > 95.00

def output_writer(diff_exp_tuple):
    '''Accept differential expression tuple and return as tab-separated string'''
    return '\t'.join(diff_exp_tuple)

# Store user input file paths
user_input_files = sys.argv

# Check user input for correct number of arguments and file extension
if len(user_input_files) != 3:
    raise Exception("Incorrect number of command-line arguments, please pass only two files.")

if not re.search(".+\.outfmt6$", user_input_files[1]):
    raise Exception('''Incorrect file extensions for first argument, 
please pass tabular BLAST output file with '.outfmt6' extension''')
    
if not re.search("diffExpr\..+\.matrix$", user_input_files[2]):
    raise Exception('''Incorrect file extensions for second argument, 
please pass Trinity differential expression FPKM matrix file with '.matrix' extension''')

# Open BLAST file and parse high identity matches into Blast objects for a dictionary
with open(user_input_files[1]) as blast_file:
    blast_list = blast_file.readlines()
    blast_obj_list = list(map(Blast, blast_list))
    high_identity_blast_dict = {blast_obj.transcript_id:blast_obj.swissprot_id
                                for blast_obj in blast_obj_list
                                if high_identity_filter(blast_obj)}

# Open differential expression file and parse each row into Matrix object
# Print differential expression information to output file and print
# error messages to error file
output_file = open('blast_to_diff_exp2_output.txt', 'w')
error_file = open('blast_to_diff_exp2_output.err', 'w')
with open(user_input_files[2]) as diff_exp_file:
    diff_exp_list = diff_exp_file.readlines()
    for diff_exp_line in diff_exp_list:
        try:
            diff_exp_obj = Matrix(diff_exp_line)
            try:
                swissprot_of_transcript = high_identity_blast_dict[diff_exp_obj.transcript]
                diff_exp_info = (
                    swissprot_of_transcript, 
                    diff_exp_obj.diauxic_shift,
                    diff_exp_obj.heat_shock,
                    diff_exp_obj.logarithmic_growth,
                    diff_exp_obj.plateau_phase)
                diff_exp_output = output_writer(diff_exp_info)
                output_file.write(diff_exp_output)
            except KeyError:
                diff_exp_info = (
                    diff_exp_obj.transcript, 
                    diff_exp_obj.diauxic_shift,
                    diff_exp_obj.heat_shock,
                    diff_exp_obj.logarithmic_growth,
                    diff_exp_obj.plateau_phase)
                diff_exp_output = output_writer(diff_exp_info)
                error_file.write("skipping line: " + diff_exp_output.rstrip('\n') + 
                                 "\twith error: no match in BLAST file\n")
        except ValueError:
            error_file.write("skipping line: " + diff_exp_line.rstrip('\n') + 
                             "\twith error: line is missing fields\n")

output_file.close()
error_file.close()
