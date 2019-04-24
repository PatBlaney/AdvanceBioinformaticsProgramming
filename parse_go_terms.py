'''
Created on Mar 22, 2019
@author: pat

Split GO term record file into individual term records, parse metadata for
each record into a GoTerm object to be stored in a dictionary. Use method to
print GO term information to output file
'''
import re

class GoTerm(object):
    
    def __init__(self, go_record):
        '''Parse GO term record by metadata to construct GoTerm object'''
        go_term_info = re.search(r'''
                                id:\s(?P<id>GO:\d+)\n
                                name:\s(?P<name>.+?)\n
                                namespace:\s(?P<namespace>.+?)\n
                                ''', go_record, re.X)
        self.id = go_term_info.group('id')
        self.name = go_term_info.group('name')
        self.namespace = go_term_info.group('namespace')
        self.is_as = re.findall('is_a: (GO:\d{7}.*?)\n', go_record)
    
    def print_term(self):
        '''Format GO term attributes for printing to output file'''
        go_attributes = self.id + '\t' + self.namespace + '\n\t' + self.name + '\n'
        for is_a in self.is_as:
            go_attributes += '\t' + is_a + '\n'
        return go_attributes
 
def go_file_splitter(input_file):
    '''Parse GO term file into records, create GoTerm objects for each record, add GoTerm objects to dictionary'''
    go_term_dict = {}
    with open(input_file) as full_go_terms_file:
        full_go_terms = full_go_terms_file.read()
        go_term_records = re.findall(r'\[Term\]\n(.*?\n)\n', full_go_terms, re.S)
        for record in go_term_records:
            go_term_obj = GoTerm(record)
            go_term_dict[go_term_obj.id] = go_term_obj
        full_go_terms_file.close()
    return go_term_dict    

go_term_dict = go_file_splitter('/scratch/go-basic.obo')
output_file = open('parsed_go_terms.txt', 'w')
for go_id in sorted(go_term_dict.keys()):
    go_term_print_output = go_term_dict[go_id].print_term()
    output_file.write(go_term_print_output + '\n')
    go_term_dict[go_id].print_term()
