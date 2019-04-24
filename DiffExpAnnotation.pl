#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';

my $gene_to_GO_file = '/scratch/gene_association_subset.txt';
my $blast_file      = '/scratch/RNASeq/blastp.outfmt6';
my $diff_exp_file   = '/scratch/RNASeq/diffExpr.P1e-3_C2.matrix';
my $GO_desc_file    = '/scratch/go-basic.obo';
my $report_file     = 'sample_report.txt';

# Open a filehandle for the gene ID to GO term.
open( GENE_TO_GO, '<', $gene_to_GO_file ) or die $!;

# Open a filehandle for the BLAST output file.
open( BLAST, '<', $blast_file ) or die $!;

# Open a filehandle for the Trinity output file.
open( DIFF_EXP, '<', $diff_exp_file ) or die $!;

# Open a filehandle for the basic GO file.
open( GO_DESC, '<', $GO_desc_file ) or die $!;

# Open a filehandle to write the report.
open( REPORT, '>', $report_file ) or die $!;

# Hash to store gene-to-GO term mappings.
my %gene_to_GO;

# Hash to store GO term-to-GO description mappings.
my %GO_to_description;

# Hash to store BLAST mappings.
my %transcript_to_protein;

read_GO_desc();
read_blast();
read_gene_to_GO();
print_report();

# Close files.
close GENE_TO_GO;
close BLAST;
close DIFF_EXP;
close GO_DESC;
close REPORT;

# Load transcript IDs of query sequence (qseqid) and SwissProt IDs of subject
# sequence (sseqid) without version number to hash for lookup.
sub read_blast {

	# Read in the BLAST file
	while (<BLAST>) {
		chomp;

	  	# Isolate the transcript ID and SwissProt ID from each BLAST line
	  	# The variables are not necessary but are used explicitly for traceability
		$_ =~ /(.*)\|(.*)\|(.*)\|(.*)\|(.*)\..\|/;
		my $transcript_id = $1;
		my $swissprot_id  = $5;

	   	# Store the transcript ID as the key and the SwissProt ID as the value in
	   	# in their respective hash
		$transcript_to_protein{$transcript_id} = $swissprot_id;
	}
}

# Load protein IDs and corresponding GO terms to hash for lookup.
sub read_gene_to_GO {

	# Read in the GO annotation file
	while (<GENE_TO_GO>) {
		chomp;

		# Isolate the protein ID and GO ID from each annotation line
		$_ =~ /\s(\w*)\s.*(GO:\d+)\s+[GP]/;
		my $protein_id = $1;
		my $go_id     = $2;

		# Only consider the first encountered GO ID for each protein ID to be stored in the hash
		if ( not defined $gene_to_GO{$protein_id} ) {

			# Store the object ID as the key and the GO ID as the value
			# in their respective hash
			$gene_to_GO{$protein_id} = $go_id;
		}
	}
}

# Load GO terms and GO descriptions to hash for lookup.
sub read_GO_desc {

	# Change the EOL from "\n" to "[Term]" so that one entire GO term record
	# will be read in for easier parsing
	local $/ = '[Term]';

	# Read in the file of filtered GO terms and annotations
	while (<GO_DESC>) {
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
}

# Sanity check, GO:2001078 this should not be in hash (error)
# but GO:2001317 should (kojic acid biosynthetic process)
#say $GO_to_description{"GO:2001078"};
#say $GO_to_description{"GO:2001317"};

# Loop through differential expression file; lookup the (SwissProt) protein ID
# + description and GO term + name; print results to REPORT output.
sub print_report {

	# Read through differential expression data file
	while (<DIFF_EXP>) {
		chomp;

		# First, grab the header then look to isolate the transcript ID and expression data points
		$_ =~ /(Sp.*at)|(^\S+)\s*(\d.*\d)/;
		my $header          = $1;
		my $transcript_id   = $2;
		my $expression_data = $3;

		# Set default values for protein ID, GO ID, GO name, and protein description to "NA",
		# overwrite this with found information
		my $swissprot_id = 'NA';
		my $go_id        = 'NA';
		my $go_name      = 'NA';
		my $protein_desc = 'NA';

		if ( defined $header ) {

			# Add the header to the beginning of the report
			print REPORT "\t$swissprot_id\t$go_id\t$header\t$go_name\t$protein_desc\n";

		}
		elsif ( defined $transcript_to_protein{$transcript_id} ) {

			# Overwrite the 'NA' for the SwissProt ID variable
			$swissprot_id = $transcript_to_protein{$transcript_id};
			
			# First check if the transcript has a GO ID
			if (defined $gene_to_GO{$swissprot_id}) {
				
				# Use new SwissProt ID to find associated GO ID
				$go_id = $gene_to_GO{$swissprot_id};
				
				# Use new GO ID to find the associated GO name
				$go_name = $GO_to_description{$go_id};
			}

			# Use SwissProt ID to find protein description
			my $protein_desc = get_protein_info_from_blast_DB($swissprot_id);

			# Add each differential expression analysis data with all identified information
			print REPORT "$transcript_id\t$swissprot_id\t$go_id\t$expression_data\t$go_name\t$protein_desc\n";

		}
		else {

	 		# Add any differentianl expression analysis data for transcript IDs with no
	 		# SwissProt IDs identified
			print REPORT "$transcript_id\t$swissprot_id\t$go_id\t$expression_data\t$go_name\t$protein_desc\n";
			
		}
	}
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
