'''
Created on Feb 21, 2019

@author: pat
'''

# Open BLAST file to read in and output file to write to
blast_file = open('/scratch/RNASeq/blastp.outfmt6')
parsed_file = open('parsed_blast.txt', 'w')

# Parse BLAST line and print information to output file
for blast_line in blast_file:
    blast_attributes = blast_line.split('\t')
    
    transcript_details = blast_attributes[0].split('|')
    transcript_id = transcript_details[0]
    isoform = transcript_details[1]
    
    protein_details = blast_attributes[1].split('|')
    swissprot_id = protein_details[3]
    
    pident = blast_attributes[2]
    
    parsed_file.write("%s\t%s\t%s\t%s\n" % (transcript_id, isoform, swissprot_id, pident))
    
blast_file.close()
parsed_file.close()