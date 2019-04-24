#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';

print_report();

# Load transcript IDs and SwissProt IDs of subject sequence without version number to hash
sub read_blast {

	# Open a filehandle for the BLAST output file.
	my $blast_file      = '/scratch/RNASeq/blastp.outfmt6';
	open( my $blast, '<', $blast_file ) or die $!;

	# Hash to store BLAST mappings
	my %transcript_to_protein;

	# Read in the BLAST file
	while (<$blast>) {
		chomp;

		# Isolate the transcript ID, SwissProt ID, and identity percentage from each BLAST line
		$_ =~ /(.*)\|(.*)\|(.*)\|(.*)\|(.*)\.\d\|.+\s(\d{2,3}\.\d+)/;
		my $transcript_id = $1;
		my $swissprot_id  = $5;
		my $identity      = $6;

		# Check that the identity is over 99% and only add the first occurance to the hash
		if ( $identity > 99.00
			&& not defined $transcript_to_protein{$transcript_id} )
		{

	   		# Store the transcript ID as the key and the SwissProt ID as the value in
	   		# in their respective hash
			$transcript_to_protein{$transcript_id} = $swissprot_id;
		}
	}

	# Close the BLAST file
	close $blast;

	# Return a hash reference of transcript IDs and associated SwissProt protein IDs
	return \%transcript_to_protein;
}

# Load protein IDs and corresponding GO terms to hash for lookup
sub read_gene_to_GO {
	
	# Hash to store gene-to-GO term mappings.
	my %gene_to_GO;

	# Open a filehandle for the gene ID to GO term.
	my $gene_to_GO_file = '/scratch/gene_association_subset.txt';
	open( my $gene_to_go, '<', $gene_to_GO_file ) or die $!;

	# Initialize a count of GO IDs per protein ID starting at zero
	my $go_count = 0;

	# Read in the GO annotation file
	while (<$gene_to_go>) {
		chomp;

		# Isolate the protein ID and GO ID from each annotation line
		$_ =~ /\s(\w+)\s.*(GO:\d+)\s+[GP]/;
		my $protein_id = $1;
		my $go_id      = $2;

		# Check if protein ID has already been added to the hash
		if ( defined $gene_to_GO{$protein_id} ) {

			# Increment the count of GO IDs for this protein ID
			$go_count++;
			
			# Store all GO IDs for each protein ID in an array
			my @all_go_ids = sort values %{$gene_to_GO{$protein_id}};
			
			# Since there are repeat GO IDs for some protein IDs and the desired
			# report only lists unique GO IDs, check if the GO ID is unique before
			# add it to the hash
		  	if ( not grep(/$go_id/, @all_go_ids) ) {
		  		
		  		# Store the protein ID as the key and the GO ID as a value in the hash
		  		# for that protein ID
				$gene_to_GO{$protein_id}->{"$go_count"} = $go_id;
		  	}
		}
		else {

			# If new protein ID, reset GO count to zero for this protein ID
			$go_count = 0;

			# Add the first entry of the array of GO IDs for this protein ID
			$gene_to_GO{$protein_id}->{"$go_count"} = $go_id;
		}
	}

	# Close the protein ID to GO ID mapping file
	close $gene_to_go;

	# Return the gene to GO ID hash as a reference
	return \%gene_to_GO;
}

# Load GO terms and GO descriptions to hash for lookup
sub read_GO_desc {

	# Open a filehandle for the basic GO terms file
	my $GO_desc_file    = '/scratch/go-basic.obo';
	open( my $go_desc, '<', $GO_desc_file ) or die $!;

	# Hash to store GO term-to-GO description mappings
	my %GO_to_description;

	# Change the EOL from "\n" to "[Term]" so that one entire GO term record
	# will be read in for easier parsing
	local $/ = '[Term]';

	# Read in the file of GO terms and annotations
	while (<$go_desc>) {
		chomp;

		# Isoalte GO ID and the GO description (name) from each GO entry
		$_ =~ /id: (GO:\S+)\nname: ([\S ]*)/;
		my $go_id   = $1;
		my $go_name = $2;

		# Check that there is no missing name or ID before adding to hash
		if ( defined $go_id && $go_name ) {

			# Store the GO ID as the key and the GO name as the value
			# in their respective hash
			$GO_to_description{$go_id} = $go_name;
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
	my $diff_exp_file   = '/scratch/RNASeq/diffExpr.P1e-3_C2.matrix';
	open( my $diff_exp, '<', $diff_exp_file ) or die $!;

	# Open a filehandle to write the report
	my $report_file     = 'report2.txt';
	open( my $report, '>', $report_file ) or die $!;

	# Get reference hash of transcript IDs and associated SwissProt protein IDs
	my $transcript_to_protein = read_blast();

	# Get reference hash of gene to GO IDs
	my $gene_to_GO = read_gene_to_GO();

	# Get reference hash of GO terms and their descriptions
	my $GO_to_description = read_GO_desc();

	# Read through differential expression data file
	while (<$diff_exp>) {
		chomp;

		# Isolate the transcript ID and expression data points: Sp_ds, Sp_hs, Sp_log, and Sp_plat
		$_ =~ /(Sp.*at)|(^\S+)\s*(\d.*\d)/;

		# Skip the header of the gene expression file
		if ( not $1 ) {

			my $transcript_id   = $2;
			my @expression_data = split( '\s+', $3 );
			my $sp_ds           = $expression_data[0];
			my $sp_hs           = $expression_data[1];
			my $sp_log          = $expression_data[2];
			my $sp_plat         = $expression_data[3];

			# Use the transcript ID within the differential expression data file to determine
			# the protien ID, GO ID, GO names, and associated protein description. Set value
			# to NA if not defined
			my $swissprot_id = $transcript_to_protein->{$transcript_id} // 'NA';
			my $protein_desc = get_protein_info_from_blast_DB($swissprot_id) // 'NA';

			# Initlaize counter to identify the beginning of new set of GO terms
			my $go_id_counter = 0;

			# SwissProt ID must not be 'NA' in order to look up GO ID and name
			if ( $swissprot_id ne 'NA' ) {

				# Use SwissProt ID to identify all associated GO IDs and then print that and 
				# linked GO name to output report2.txt
				foreach my $go_id ( sort values %{ $gene_to_GO->{$swissprot_id} } ) {
					
					# Increment the counter after each GO ID
					$go_id_counter++;
					
					# Look up the GO name using the GO ID
					my $go_name = $GO_to_description->{$go_id} // 'NA';
					
					# If first GO ID, print all other meta data
					if ( $go_id_counter == 1 ) {
						
						print $report
						"$transcript_id\t$sp_ds\t$sp_hs\t$sp_log\t$sp_plat\t$swissprot_id\t$go_id\t$go_name\t$protein_desc\n";
					} 
					else {
						
						# Print rest of GO IDs with linked GO name after first line
						print $report "\t" x 6, "$go_id\t$go_name\t\n";	
					}
				}
			}
		}
	}

	# Close the differential expression data file and report file
	close $diff_exp;
	close $report;
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
