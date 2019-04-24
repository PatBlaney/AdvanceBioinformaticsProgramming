'''
Created on Feb 23, 2019

@author: pat
'''

# Open BLAST file to read in
blast_file = open('/scratch/RNASeq/blastp.outfmt6')

# Parse each BLAST line and return message based on percent identity
def blast_analyzer(blast_line):
    # Open output file to write to
    analysis_file = open('blast_analysis.txt', 'w')
    
    blast_attributes = blast_line.split('\t')
    
    transcript_details = blast_attributes[0].split('|')
    transcript_id = transcript_details[0]
    
    protein_details = blast_attributes[1].split('|')
    swissprot_id_versioned = protein_details[3]
    swissprot_id =  swissprot_id_versioned.split('.')
    
    pident = float(blast_attributes[2])
    
    if pident == 100.00:
        match_message = transcript_id + " is a perfect match for " + swissprot_id[0]
        analysis_file.write("\t".join([match_message, str(pident), "\n"]))
    
    elif pident > 75.00 and pident < 100.00:
        match_message = transcript_id + " is a good match for " + swissprot_id[0]
        analysis_file.write("\t".join([match_message, str(pident), "\n"]))

    elif pident > 50.00 and pident < 75.00:
        match_message = transcript_id + " is a fair match for " + swissprot_id[0]
        analysis_file.write("\t".join([match_message, str(pident), "\n"]))
        
    else:
        match_message = transcript_id + " is a bad match for " + swissprot_id[0]
        analysis_file.write("\t".join([match_message, str(pident), "\n"]))
        
# Call the BLAST analyzer for each line in BLAST file    
for line in blast_file:
    blast_analyzer(line)
    
# Test BLAST analyzer function for correct output
#assert blast_analyzer("c1004_g1_i1|m.804\tgi|74676184|sp|O94325.1|PEX5_SCHPO\t100.00") == "c1004_g1_i1 is a perfect match for O94325\t100.0\n"

# Close both opened files
blast_file.close()
