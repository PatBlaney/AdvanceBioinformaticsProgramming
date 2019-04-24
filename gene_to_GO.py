'''
Created on Mar 15, 2019
@author: pat

Parse GO term and GO annotation files, create dictionaries of all possible GO terms
and all GO terms associated with each protein ID, output all protein IDs with
each direct GO term and all parent GO terms
'''
import re

def go_file_splitter(input_filename):
    '''Split GO term file into list of individual term records'''
    input_file= open(input_filename)
    full_go_terms_file = input_file.read()
    input_file.close()
    go_term_records = re.findall(r'\[Term\]\n(.*?)\n\n', full_go_terms_file, re.S)
    return go_term_records

def go_record_parser(go_record):
    '''Isolate and return GO ID and all parent GO term IDs'''
    go_id = re.match(r'id: (GO:\d+)', go_record)
    is_a_list = re.findall(r'^is_a: (GO:\d+)', go_record, re.M)
    return go_id.group(1), is_a_list

def go_dictionary_creater():
    '''Create dictionary of all GO IDs and associated is_as'''
    go_dict = {}
    go_terms_file = '/scratch/go-basic.obo'
    go_records = go_file_splitter(go_terms_file)
    for term in go_records:
        (go_id, is_as) = go_record_parser(term)
        go_dict[go_id] = is_as
    return go_dict

def go_annotation_parser(input_filename):
    '''Create dictionary of protein IDs and associated unique GO IDs'''
    go_annotation_file = open(input_filename)
    annotation_dict = {}
    for line in go_annotation_file:
        annotations = line.split('\t')
        protein_id = annotations[1]
        go_id = annotations[4]
        if protein_id not in annotation_dict.keys():
            annotation_dict[protein_id] = {go_id}
        else:
            annotation_dict[protein_id].add(go_id)
    return annotation_dict

go_term_dict = go_dictionary_creater()
go_annotation_dict = go_annotation_parser('/scratch/gene_association_subset.txt')

def go_parent_term_finder(go_term_id):
    if go_term_dict.get(go_term_id):
        for test1 in sorted(go_term_dict.get(go_term_id)):
            print('\t\t' + test1)
            go_parent_term_finder(test1)

for protein_id in sorted(go_annotation_dict.keys()):
    print(protein_id)
    for child_go_id in sorted(go_annotation_dict.get(protein_id)):
        print('\t' + child_go_id)
        go_parent_term_finder(child_go_id)
