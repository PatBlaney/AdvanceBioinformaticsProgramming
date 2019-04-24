#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';
use BLAST;
use GO;
use DiffExp;
use Report;

print_report();

# Use BLAST package to parse input BLAST file into hash of BLAST objects
sub read_blast {

	# Open a filehandle for the BLAST output file.
	my $blast_filename      = '/scratch/RNASeq/blastp.outfmt6';
	open( my $blast_file, '<', $blast_filename ) or die $!;

	# Hash to store BLAST objects
	my %transcript_to_protein;

	# Read in the BLAST file
	while (<$blast_file>) {
		chomp;

		# Instantiate a new BLAST object and set its attributues
		my $blast = BLAST->new( blast_line => $_ );

		# Check that the identity is over 99% for each transcript and only add the first occurance to the hash
		if ( $blast->get_pident() > 99
			&& not defined $transcript_to_protein{$blast->get_transcript()} )
		{

	   		# Store the BLAST object using the transcript ID as the key
			$transcript_to_protein{$blast->get_transcript()} = $blast;
		}
	}

	# Close the BLAST file
	close $blast_file;

	# Return a hash reference of BLAST objects
	return \%transcript_to_protein;
}

# Load protein IDs and corresponding GO terms to hash for lookup
sub read_gene_to_GO {
	
	# Hash to store gene-to-GO term mappings.
	my %gene_to_GO;

	# Call subroutine to get hash all GO objects
	my $GO_to_description = read_GO_desc();

	# Open a filehandle for the gene ID to GO term.
	my $gene_to_GO_file = '/scratch/gene_association_subset.txt';
	open( my $gene_to_go, '<', $gene_to_GO_file ) or die $!;

	# Read in the GO annotation file
	while (<$gene_to_go>) {
		chomp;

		# Isolate the protein ID and GO ID from each annotation line
		$_ =~ /\s(\w+)\s.*(GO:\d+)\s+(GO_REF|PMID)/;
		my $protein_id = $1;
		my $go_id      = $2;

		# Check if both SwissProt ID and GO ID are defined
		if (defined $protein_id && defined $go_id) {
			
			# Store the protein ID as the key of the main level 
			# and then the GO ID as the key of second level, this eliminates
			# duplication of GO IDs, set corresponding GO description as 
			# value
			$gene_to_GO{$protein_id}{$go_id} = $GO_to_description->{$go_id} // 'NA';
		}
	}

	# Close the protein ID to GO ID mapping file
	close $gene_to_go;

	# Return the gene to GO ID hash as a reference
	return \%gene_to_GO;
}

# Use GO package to parse input GO Term file into hash of GO objects
sub read_GO_desc {

	# Open a filehandle for the basic GO terms file
	my $GO_desc_file    = '/scratch/go-basic.obo';
	open( my $go_desc, '<', $GO_desc_file ) or die $!;

	# Hash to store GO objects
	my %GO_to_description;

	# Change the EOL from "\n" to "[Term]" so that one entire GO term record
	# will be read in for easier parsing
	local $/ = '[Term]';

	# Read in the file of GO terms and annotations
	while (<$go_desc>) {
		chomp;

		# Instantiate new GO object and set its attributes
		my $go = GO->new( record => $_ );

		# Check that there is both GO name and ID before adding to hash
		if ( $go->get_id() && $go->get_name() ) {

			# Store the GO object using GO ID as the key 
			$GO_to_description{$go->get_id()} = $go;
		}
	}

	# Close the GO term description mapping file
	close $go_desc;

	# Return the hash of go descriptions as a reference
	return \%GO_to_description;
}

# Loop through differential expression file; lookup the (SwissProt) protein ID,
# description, GO term, and name; print results to report2.txt output file
sub print_report {

	# Open a filehandle for the Trinity differential expression data file
	my $diff_exp_filename   = '/scratch/RNASeq/diffExpr.P1e-3_C2.matrix';
	open( my $diff_exp_file, '<', $diff_exp_filename ) or die $!;

	# Get reference hash of BLAST objects
	my $transcript_to_protein = read_blast();

	# Get reference hash of gene to GO objects
	my $gene_to_GO = read_gene_to_GO();

	# Read through differential expression data file
	while (<$diff_exp_file>) {
		chomp;
	
		# Instantiate new DiffExp object and set its attributes
		my $diff_exp = DiffExp->new( diff_exp_line => $_ );

		# Check if entry has transcript ID
		if( defined $diff_exp->get_transcript()) {
		
			# Use the transcript ID within the differential expression data file to
			# identify the corresponding BLAST object, 
			my $blast = $transcript_to_protein->{$diff_exp->get_transcript()} // 'NA';
			
			# Make sure BLAST object is valid
			if($blast ne 'NA') {
				
				# Use BLAST object to identify entry protein ID and associate description
				my $protein_id = $blast->get_sp();
				my $protein_desc = get_protein_info_from_blast_DB($protein_id);	
				
				# Resort all GO objects so all GO IDs are sequential
				my @GO_objs;
				foreach my $sorted_go_id (sort keys %{$gene_to_GO->{$protein_id}}) {
					
					push(@GO_objs, $gene_to_GO->{$protein_id}{$sorted_go_id} );
				}
				
				# Instantiate a new Report object and set its attributues
				my $report_obj = Report->new( diff_exp => $diff_exp,
											  protein_id => $protein_id,
											  protein_desc => $protein_desc,
											  GO_terms => \@GO_objs
				);
				
				# Use Report object method to output final report
				$report_obj->print_all();
			}
		}
	}

	# Close the differential expression data file
	close $diff_exp_file;
}

# Get description of the given protein ID from the SwissProt BLAST database.
sub get_protein_info_from_blast_DB {

	# Accept SwissProt protein ID as input
	my ($protein_id) = @_;

	# Initialize variables for the SwissProt BLAST database path and the
	# command line BLAST argument
	my $db = '/blastDB/swissprot';
	my $exec =
	    'blastdbcmd -db '
	  . $db
	  . ' -entry '
	  . $protein_id
	  . ' -outfmt "%t" -target_only | ';

	open( SYSCALL, $exec ) or die "Can't open the SYSCALL ", $!;

	# Set default description as "NA". If protein is found in DB, overwrite
	# description.
	my $protein_description = 'NA';
	while (<SYSCALL>) {
		chomp;

		# If protein description exists, overwrite the default "NA"
		if ( $_ =~ /RecName:\s+(.*)/i ) {
			$protein_description = $1;
		}
	}
	close SYSCALL;

	# Return the protein description from the subroutine so it can be integrated
	# into the output report.txt file
	return $protein_description;
}
